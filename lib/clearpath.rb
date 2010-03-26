require 'mechanize'

class Clearpath
  HOST = 'https://ews2.cpmvp.net'.freeze
  FORWARD_DELAY = { :day => 15, :night => 1 }.freeze

  attr_reader :page

  def initialize(username, password)
    @username = username
    @password = password
  end

  def set_forward_delay(name, mode)
    raise ArgumentError.new('Invalid mode.') unless FORWARD_DELAY[mode]

    hunt_group(name)

    page.form_with(:name => 'mainForm') do |form|
      form.checkbox_with(:name => 'enableCFGNAExternal').check
      form['cfgnaExternalSeconds'] = FORWARD_DELAY[mode]
    end.submit
  end

  def hunt_group(name)
    login
    get("/Group/Hunt_Group/")

    href = page.link_with(:text => name).href
    key = href.match(/key=(.*?)&/).to_a.last
    get("/Group/Hunt_Group/Modify/index.jsp?key=#{key}")
  end

  def login
    unless @logged_in
      get("#{HOST}/Login/")

      page.form_with(:name => 'loginForm') do |form|
        form['UserID'] = @username
        form['Password'] = @password
      end.submit

      @logged_in = true
    end
  end

  def get(url)
    @page = agent.get(url)

    if @page.send(:html_body) =~ /top\.location\.replace\("(.*?)"\);/
      location = $1
      get(location) unless location =~ /logout/i
    end
  end
  protected :get

  def agent
    @agent ||= Mechanize.new do |agent|
      agent.keep_alive = false # workaround for issue with SSL verification
      agent.user_agent_alias = 'Mac Safari'
    end
  end
  protected :agent

  def dom
    Nokogiri.parse(page.body)
  end
  protected :dom
end
