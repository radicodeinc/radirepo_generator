
module DailyReportGenerator 
  class Generator
    attr_accessor :file

    def self.generate(reports = {})
      template = File.read("./templates/#{ENV['REPORT_TEMPLATE']}")
      erb = ERB.new(template, 0, '%-')
      result(erb, reports)
    end

    def self.today_report_dir
      today = Time.zone.now
      "./reports/#{today.year}"
    end

    def self.today_report_file
      today = Time.zone.now
      dir = today_report_dir
      "#{dir}/#{today.year}-#{sprintf('%02d', today.month)}-#{sprintf('%02d', today.day)}.md"
    end

    def self.result(erb, reports)
      erb.result(binding)
    end
  end
end

