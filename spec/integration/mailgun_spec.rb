require 'spec_helper'
require 'mailgun'

vcr_opts = { :cassette_name => "instance" }

describe 'Mailgun instantiation', vcr: vcr_opts do
  it 'instantiates an HttpClient object' do
    expect {@mg_obj = Mailgun::Client.new(APIKEY, APIHOST, APIVERSION, SSL)}.not_to raise_error
  end
end

vcr_opts = { :cassette_name => "send_message" }

describe 'The method send_message()', vcr: vcr_opts do
  before(:all) do
    @mg_obj = Mailgun::Client.new(APIKEY, APIHOST, APIVERSION, SSL)
    @domain = TESTDOMAIN
  end
  
  it 'sends a standard message in test mode.' do
    result = @mg_obj.send_message(@domain, {:from => "bob@#{@domain}",
                                    :to => "sally@#{@domain}",
                                    :subject => 'Hash Integration Test',
                                    :text => 'INTEGRATION TESTING',
                                    'o:testmode' => true}
                                  )
    result.to_h!
    expect(result.body).to include("message")
    expect(result.body).to include("id")
  end

  it 'sends a message builder message in test mode.' do
    mb_obj = Mailgun::MessageBuilder.new()
    mb_obj.from("sender@#{@domain}", {'first' => 'Sending', 'last' => 'User'})
    mb_obj.add_recipient(:to, "recipient@#{@domain}", {'first' => 'Recipient', 'last' => 'User'})
    mb_obj.subject("Message Builder Integration Test")
    mb_obj.body_text("This is the text body.")
    mb_obj.test_mode(true)

    result = @mg_obj.send_message(@domain, mb_obj)

    result.to_h!
    expect(result.body).to include("message")
    expect(result.body).to include("id")
  end

  it 'sends a custom MIME message in test mode.' do
    mime_string = 'Delivered-To: mgbox01@gmail.com
Received: by luna.mailgun.net with HTTP; Tue, 26 Nov 2013 17:59:11 +0000
Mime-Version: 1.0
Content-Type: text/plain; charset="ascii"
Subject: Hello
From: Excited User <me@samples.mailgun.org>
To: sally@example.com
Message-Id: <20131126175911.25310.92289@samples.mailgun.org>
Content-Transfer-Encoding: 7bit
X-Mailgun-Sid: WyI2NTU4MSIsICJtZ2JveDAxQGdtYWlsLmNvbSIsICIxZmYiXQ==
Date: Tue, 26 Nov 2013 17:59:22 +0000
X-Mailgun-Drop-Message: yes
Sender: me@samples.mailgun.org

Testing some Mailgun awesomness!'

    message_params = {:to => "sally@#{@domain}",
                      :message => mime_string}

    result = @mg_obj.send_message(@domain, message_params)

    result.to_h!
    expect(result.body).to include("message")
    expect(result.body).to include("id")
  end
end

