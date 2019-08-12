class GustSpider < Kimurai::Base
  @name = "gust_spider"
  @engine = :selenium_chrome
  @start_urls = ["https://gust.com/search/new?category=startups&page=1&partial=results"]
  @config = {
      user_agent: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.84 Safari/537.36",
      before_request: { delay: 1..3 }
  }

  # TODO: redis state: current_page/status

  def parse(response, url:, data: {})
    response.xpath("//div[@id='search_results']//li[@class='list-group-item']//div[@class='card-title']/a")
            .each do |company_link|

      company = { name: company_link.text,
                  href: company_link[:href] }

      request_to :parse_company_page, url: absolute_url(company[:href], base: url), data: company
    end


    index = /page=(\d+)/.match(url)[1].to_i
    return if index == 2

    next_page = response.at_xpath("//div[@id='search_results']//li[@class='last']/a")
    request_to :parse, url: absolute_url(next_page[:href], base: url) if next_page
  end

  def parse_company_page(response, url:, data: {})
    logger.debug "=========="
    logger.debug "Parsing #{ data[:name] } at #{ data[:href] }"

    company = fetch_company(response).merge(parsed_at: Time.now,
                                            users: fetch_users(response))

    logger.debug company.to_s
    logger.debug "=========="
  end

  private

  def tag_by_section(section)
    case section
    when 'management' then 'team'
    when 'advisors'   then 'advisors'
    when 'investor'   then 'previous_investors'
    else nil
    end
  end

  def fetch_company(response)
    company = {
      name: response.at_xpath("//div[@id='company_info']//h2")&.text,
      slogan: response.at_xpath("//div[@id='company_info']//p[contains(@class, 'quote')]")&.text,
      overview: response.at_xpath("//div[@id='company_overview']//div[contains(@class, 'panel-body')]/p")&.text
    }

    list_xpath = "//div[@id='company_info']//ul/li[@class='list-group-item']"
    response.xpath(list_xpath).each do |item|
      column = item.text.split[0].downcase.to_sym
      value  = item.at_xpath("./span[contains(@class, 'value')]")&.text
      case column
      when :website then value = item.at_xpath("./span[contains(@class, 'value')]/a")[:href]
      when :incorporation then column = :incorporation_type
      else nil
      end
      company[column] = value
    end
    company.transform_values { |v| v&.strip }
  end

  def fetch_users(response)
    users = []

    team_xpath = "//div[@id='management']//li[contains(@class, 'list-group-item')]//div[@class='row']"
    response.xpath(team_xpath).each do |user|
      item = {}
      user_title = user.at_xpath(".//div[contains(@class, 'card')]//div[@class='card-title']")
      user_link = user.at_xpath(".//div[contains(@class, 'card')]//div[@class='card-title']/a")
      item[:href] = user_link&.send(:[], :href)
      item[:name] = user_link&.text || user_title&.text
      item[:role] = user.at_xpath(".//div[contains(@class, 'card')]//div[@class='card-subtitle']")&.text
      item[:description] = user.at_xpath("./div[@class='col-md-7']")&.text
      item[:tag] = tag_by_section('management')
      users << item.transform_values { |v| v&.strip }
    end

    %w(advisors investor).each do |section|
      card_xpath = "//div[@id='#{section}']//li[contains(@class, 'list-group-item')]//div[@class='card-title']"
      response.xpath(card_xpath).each do |user|
        item = {}
        user_link = user.at_xpath("./a")
        item[:href] = user_link&.send(:[], :href)
        item[:name] = user_link&.text || user&.text
        item[:tag] = tag_by_section(section)
        users << item.transform_values { |v| v&.strip }
      end
    end

    users
  end
end
