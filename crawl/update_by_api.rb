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
      results = JSON.parse(open(website).read())
      cpids = []
      ap results
      results[:casts].to_a.each do |cast|
        cpids << cast.avatars.medium
      end

      dpids = []
      results[:directors].to_a.each do |d|
        dpids << d.avatars.small
      end
      rate = nil
      if results.respond_to?(:rating)
        rate = results[:rating][:average]
      end
      image = nil
      if results.respond_to?(:images)
        img = results[:images][:large]
      end
      Movie.where(rate: nil).update(
        rate: rate ,
        summary: results[:summary],
        cover_id: img ,
        directors_pids: dpids,
        casts_pids: cpids
      )
      print "Pid:#{Process.pid}, fetch:#{website}, #{results[:reate]} by #{results[:summary]}\n"
      results
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
sites = []
puts "还有 #{Movie.where(rate: nil).count} 个没信息"
Movie.where(rate: nil).each_with_index do |m, i|
  if i < 5
    site = "https://api.douban.com/v2/movie/subject/#{m.movie_id}/"
    puts site
    sites << site
  else
    break
  end
end
results = MultipleCrawler.new(sites, beanstalk_jobs, pm_max, user_agent).run
=begin
1994.downto(1960) do |age|
  start = 0
  start = 15 if age == 2010
  11.upto(50) do |i|
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
