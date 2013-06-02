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
        puts doc
        doc.css("span.rating").each do |link|
          results[:rate] =  link.content.chomp if link.content
          puts link.content.chomp
          puts results[:rate]
        end

        doc.css("a.nbg").each do |link|
          results[:cover_id] = link.attributes[:href]
          puts results[:cover_id]
        end

        Movie.where(rate: nil).update(
          rate: results[:rate],
          cover_id: results[:cover_id] 
        )
        print "Pid:#{Process.pid},#{results[:cover_id]},#{results[:rate]}\n"
        results
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

sites = []
beanstalk_jobs = [['localhost:11300'],'crawler-jobs']
user_agent = "Mozilla/5.0 (iPhone; CPU iPhone OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3"
pm_max = 40
counts = 0
puts "还有 #{Movie.where(rate: nil).count} 个没信息"
Movie.where(rate: nil).each_with_index do |m, i|
  if i < 100
    site = "http://m.douban.com/movie/subject/#{m.movie_id}/?session=210a9073_2790109"
    sites << site
  else
    break
  end
end
results = MultipleCrawler.new(sites, beanstalk_jobs, pm_max, user_agent).run
