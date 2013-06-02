%w[ap set json open-uri net/http nokogiri forkmanager beanstalk-client].each {|p| require p}
require_relative "model"

class MultipleCrawler

  class Crawler
    def initialize(user_agent, redirect_limit=1)
      @user_agent = user_agent
      @redirect_limit = redirect_limit
      @timeout = 2000
    end
    attr_accessor :user_agent, :redirect_limit, :timeout
    
    def fetch(website)
      movie_id = website.split("/")[-1]
      redirect, url = @redirect_limit, website
      start_time = Time.now
      redirecting = false
      begin
        res = nil
        begin
          uri = URI.parse(url)
          req = Net::HTTP::Get.new(uri.path)
          req.add_field('User-Agent', @user_agent)
          res = Net::HTTP.start(uri.host, uri.port) do |http|
            http.read_timeout = @timeout
            http.request(req)
          end 
          if res.header['location'] # 遇到重定向，则url设定为location，再次抓取
            url = res.header['location'] 
            redirecting = true
          end
          redirect -= 1
        end while redirecting and redirect>=0 and !res
        opened_time = (Time.now - start_time).round(4) # 统计打开网站耗时
        encoding = res.body.scan(/<meta.+?charset=["'\s]*([\w-]+)/i)[0]
        encoding = encoding ? encoding[0].upcase : 'GB18030'
        html = 'UTF-8'== encoding ? res.body : res.body.force_encoding('GB2312'==encoding || 'GBK'==encoding ? 'GB18030' : encoding).encode('UTF-8') 
        doc = Nokogiri::HTML(html)
        processed_time = (Time.now - start_time - opened_time).round(4) # 统计分析链接耗时, 1.8.7, ('%.4f' % float).to_f 替换 round(4)
        #[opened_time, processed_time, doc.css('div#info').size]
        results = {}
        results[:movie_id] = url.split("/")[-1]
        doc.css("strong.ll.rating_num").each do |num|
          results[:num] = num.content if num
        end
        people = doc.css("div.rating_wrap p")[1]
        results[:people] = people.content[/\d+/] if people
        results[:name] = doc.css("h1 span").first.content
        year = doc.css("span.year").first
        results[:year] = year.content.gsub(/\(|\)/, "") if year
        doc.css('div#info').each do |link|
          content = link.content.gsub("\s", "")
          directors = content[/(?<=导演:)(.*)(?=编剧)/]
          directors = content[/(?<=导演:)(.*)(?=主演)/] unless directors
          directors = content[/(?<=导演:)(.*)(?=类型)/] unless directors
          directors = content[/(?<=导演:)(.*)(?=制片国家)/] unless directors
          directors = directors.split("/") if directors
          editors = content[/(?<=编剧:)(.*)(?=主演)/]
          editors = editors.split("/") if editors
          actors = content[/(?<=主演:)(.*)(?=类型)/]
          actors = content[/(?<=主演:)(.*)(?=官方网站)/] unless actors
          actors = content[/(?<=主演:)(.*)(?=制片国家)/] unless actors
          actors = actors.split("/") if actors
          types = content[/(?<=类型:)(.*)(?=官方网站)/]
          types = types.split("/") if types
          types = content[/(?<=类型:)(.*)(?=制片国家)/] unless types
          types = types.split("/") if types
          countries = content[/(?<=地区:)(.*)(?=语言)/]
          countries = countries.split("/") if countries
          language = content[/(?<=语言:)(.*)(?=上映日期)/]
          language = content[/(?<=语言:)(.*)(?=首播)/] unless language
          language = language.split("/") if language
          date = content[/(?<=日期:)(.*)(?=片长)/]
          date = content[/(?<=日期:)(.*)(?=IMDb)/] unless date
          date = date.split("(").first if date
          length = content[/(?<=片长:)(.*)(?=又名)/]
          length = length[/\d+/] if length
          results.update({
            directors: directors, 
            editors: editors,
            actors: actors,
            types: types,
            countries: countries,
            language: language,
            date: date,
            length: length
          })
        end
        results[:tags] = []
        doc.css("div.tags-body a").each do |link|
          results[:tags] << link.content.split("(").first()
        end
        if results[:name] and not Movie.where(name: results[:name]).exists?
          movie = Movie.new(
            name: results[:name], 
            directors: results[:directors],
            editors: results[:editors],
            actors: results[:actors],
            types: results[:types],
            countries: results[:results],
            language: results[:language],
            date: results[:date],
            length: results[:length],
            tags: results[:tags],
            rate: results[:rate],
            year: results[:year],
            people: results[:people],
            movie_id: results[:movie_id]
          )
          movie.save!
        elsif results[:name] =~ /403/
          puts "又403了 让我睡一觉"
          sleep 200
        end
        print "Pid:#{Process.pid}, fetch: #{website},#{results[:name]} by #{results[:directors]},#{results[:num]}\n"
        results
      rescue =>e
        puts e.message  
      end
    end
  end

  def initialize(websites, beanstalk_jobs, pm_max=1, user_agent='', redirect_limit=1)
    @websites = websites          # 网址数组 
    @beanstalk_jobs = beanstalk_jobs  # beanstalk服务器地址和管道参数
    @pm_max = pm_max          # 最大并行运行进程数
    @user_agent = user_agent      # user_agent 伪装成浏览器访问
    @redirect_limit = redirect_limit    # 允许最大重定向次数

    @ipc_reader, @ipc_writer = IO.pipe # 缓存结果的 ipc 管道
  end

  attr_accessor :user_agent, :redirect_limit

  def init_beanstalk_jobs # 准备beanstalk任务
    beanstalk = Beanstalk::Pool.new(*@beanstalk_jobs)
    #清空beanstalk的残留消息队列
    begin
      while job = beanstalk.reserve(0.1) 
        job.delete
      end
    rescue Beanstalk::TimedOut
      print "Beanstalk queues cleared!\n"
    end
    @websites.size.times{|i| beanstalk.put(i)} # 将所有的任务压栈
    beanstalk.close
  end

  def process_jobs # 处理任务
    start_time = Time.now
    pm = Parallel::ForkManager.new(@pm_max)
    sites = []
    @pm_max.times do |i| 
      pm.start(i) and next # 启动后，立刻 next 不会等待进程执行完，这样才可以并行运算
      beanstalk = Beanstalk::Pool.new(*@beanstalk_jobs)
      @ipc_reader.close  # 关闭读取管道，子进程只返回数据
      loop{ 
        begin
          job = beanstalk.reserve(0.1) # 检测超时为0.1秒，因为任务以前提前压栈
          index = job.body
          job.delete
          website = @websites[index.to_i]
          result = Crawler.new(@user_agent).fetch(website)
          sleep Random.rand(15)
          @ipc_writer.puts( ({website=>result}).to_json )
        rescue Beanstalk::DeadlineSoonError, Beanstalk::TimedOut, SystemExit, Interrupt
          break
        end
      }
      @ipc_writer.close
      pm.finish(0)  
    end
    @ipc_writer.close

    begin 
      pm.wait_all_children    # 等待所有子进程处理完毕 
    rescue SystemExit, Interrupt  # 遇到中断，打印消息
      print "Interrupt wait all children!\n"
    ensure
      begin
        results = read_results
      rescue
      end
      #ap results, :indent => -4 , :index=>false # 打印处理结果
      #@websites = results[:sites]
      #print "Process end, total: #{@websites.size}, crawled: #{results.size}, time: #{'%.4f' % (Time.now - start_time)}s.\n"
      results.values.each do |result|
        sites << result["sites"] if result
      end if results and results.values
    end
    sites.uniq.flatten
  end

  def read_results # 通过管道读取子进程抓取返回的数据
    results = {}
    while result = @ipc_reader.gets
      results.merge! JSON.parse(result)
    end
    @ipc_reader.close
    results
  end

  def run # 运行入口
    init_beanstalk_jobs
    process_jobs
  end
end

def get_links(age, page)
  puts "grabing #{age} page #{page} ing"
  start = page.to_i * 20
  url = "http://movie.douban.com/tag/#{age}?start=#{start}"
  begin
    doc = Nokogiri::HTML(open(url))
  rescue
    puts "居然在取链接的时候又403了 让我睡一觉"
    sleep 200
    begin
      doc = Nokogiri::HTML(open(url))
    rescue
      puts "居然在取链接的时候又403了 让我睡一觉"
      sleep 300
      begin
        doc = Nokogiri::HTML(open(url))
      rescue
        sleep 500
        doc = Nokogiri::HTML(open(url))
      end
    end
  end
  links = []
  doc.css(".pl2 a").each do |link|
    href = link.attributes["href"].content
    if href =~ /subject/
      links << href
    end
  end
  links
end
#2013 50
#2012 46
#2011 49
#2010 
#2009 
#2008 
#2007 
#2006 
#2005 
#1960 
#1961 
#1962 
#
beanstalk_jobs = [['localhost:11300'],'crawler-jobs']
user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.7; rv:13.0) Gecko/20100101 Firefox/13.0'
pm_max = 40
counts = 0
=begin
1988.downto(1960) do |age|
  start = 0
  start = 7 if age == 1990
  start.upto(10) do |i|
    sites = get_links(age, i)
    results = MultipleCrawler.new(sites, beanstalk_jobs, pm_max, user_agent).run
    if results.empty?
      puts "结果为空 再来试试"
      counts += 1
      print counts
      break if counts > 1
    end
  end
end
=end
# 2008 41
=begin
sites = []
puts "还有 #{Movie.where(directors: nil).count} 个没信息"
Movie.where(directors: nil).each do |m|
  site = "http://movie.douban.com/subject/#{m.movie_id}/"
  sites << site
end
results = MultipleCrawler.new(sites, beanstalk_jobs, pm_max, user_agent).run
=end


#1992 19
1991.downto(1960) do |age|
  start = 11
  start = 22 if age.to_i == 1991
  start.upto(50) do |i|
    sites = get_links(age, i)
    results = MultipleCrawler.new(sites, beanstalk_jobs, pm_max, user_agent).run
    if results.empty?
      puts "结果为空 再来试试"
      counts += 1
      print counts
      break if counts > 1
    end
  end
end
