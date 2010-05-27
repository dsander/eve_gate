require "active_support"
require "mechanize"
require 'openssl'

class EveGate
  class Mail
    attr_accessor :receipient, :subject, :read
    #attr_writer :body, :sender, :to
    def initialize(mail, agent)
      @read =     mail.children[2].children[1].attributes['alt'].text == 'Read'
      @sender =   mail.children[4].children[1].text.strip
      @subject =  mail.children[6].children[1].children[1].text
      @url =      mail.children[6].children[1].children[1].attributes['href'].value
      @date = DateTime.parse(mail.children[8].text).to_time
      @agent = agent
    end
    
    def body
      update_details unless @body
      @body
    end
    
    def sender
      update_details unless @sender
      @sender
    end
    
    def to
      update_details unless @to
      @to
    end
    
    def update_details
      @agent.get(@url)
      @body   = @agent.page.search(".//div[@id='hideBottomButtons']/p")[1].inner_html
      @to     = @agent.page.search(".//div[@id='hideBottomButtons']/p[1]/a")[1].text
      @sender = @agent.page.search(".//div[@id='hideBottomButtons']/p[1]/a")[0].text
    end
  end

  def initialize(user, pass, character)
    @user = user
    @pass = pass
    @character = character
    @agent = Mechanize.new
    @page = nil
    @characters = {}
    login
  end
  
  def login
    begin
      @page = @agent.get('https://www.evegate.com/')
    rescue Mechanize::ResponseCodeError
      puts "EveGate is currently not available."
      exit -1
    end
    
    login_form = @page.form_with(:action => "/LogOn/Logon")
    login_form['username'] = @user
    login_form['password'] = @pass
    @agent.submit(login_form, login_form.button_with(:value => 'Log On'))
    
    if error = @agent.page.search(".//ul[@class='logOnErrorMessages']/li") 
      if error.text.include? 'EVE Gate is currently not accepting new logins'
        puts "EVE Gate is currently not accepting new logins"
        exit -1
      end
    end
        
    if @agent.page.links_with(:href => /\/Account\/SwitchCharacter\?characterName=#{@character.gsub(' ', '%20')}/).length != 0
      puts "switch char"
      @agent.page.links_with(:href => /\/Account\/SwitchCharacter\?characterName=#{@character.gsub(' ', '%20')}/)[0].click
    end
    if @agent.page.links_with(:href => /\/Account\/LogOnCharacter\?characterName=#{@character.gsub(' ', '%20')}/).length != 0
      puts "logong char"
      @agent.page.links_with(:href => /\/Account\/LogOnCharacter\?characterName=#{@character.gsub(' ', '%20')}/)[0].click
    end
    if @character != current_character
      raise "Could not select #{@character}."
    end
  end
  
  def eve_mails
    @agent.get('/Mail/Inbox')
    parse_mails
  end
  
  def corporation_mails
    @agent.get('/Mail/Corp')
    parse_mails
  end
  
  def alliance_mails
    @agent.get('/Mail/Alliance')
    parse_mails
  end
    
  def send_mail(to, subject, text)
    @agent.get('/Mail/Compose')
    mail_form = @agent.page.forms_with(:action => "/Mail/SendMessage").first
    mail_form['recipientLine'] = to
    mail_form['subject'] = subject
    mail_form['message'] = text
    mail_form['mailContents'] = text
    @agent.submit(mail_form, mail_form.button_with(:value => 'Send'))
    
    @agent.page.code == "200"
  end
  
  def current_character
    begin
      c1 = @agent.page.search(".//div[@id='activeCharacterContent']/div/div/h1").text
      return c1 if c1 != ""
      c2 = @agent.page.search(".//div[@id='sectionHeaderContainer']/div/span").text.gsub(' Contacts Chatter','')
      return c2 if c2 != ""
    rescue
      raise "Error getting current character."
    end
  end
  
  private
  def dump_page
    File.open('page', 'w') { |f|  f.write @agent.page.parser }
  end
  
  def parse_mails
    mails = []
    @agent.page.search(".//table[@id='mailTable']/tbody/tr").each do |mail|
       mails << Mail.new(mail, @agent)
    end
    mails
  end
end