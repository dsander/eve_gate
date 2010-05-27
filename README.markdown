# eve_gate: A Ruby interface to EVE Gate

## Disclaimer

I wrote the library for educational purposes only! 
CCP Karuck stated that "Crawling EVE Gate is forbidden as part of our soon to be updated Terms of Service, and can be a basis for an account ban.", even though eve_gate does not support crawling - it just *uses* the site as a normal user would do - do not use it unless you are willing to risk your account.

Furthermore it would be nice to get statement from CCP if viewing and writing evemails is considered "crawling".

I hope that CCP will actually release a complete eve mail api with write support, so there is no need for this library anymore.

## Installation

	sudo gem install eve_gate
  
## Usage

	require 'eve_gate'
	g = EveGate.new('username', 'password', 'character')
	
	g.send_mail('Makurid', 'eve_gate', 'rocksalot!')
	
	puts g.eve_mails.first.body
	puts g.alliance_mails.first.body
	puts g.corporation_mails.frist.body

## Note on Patches/Pull Requests
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2010 Dominik Sander. See LICENSE for details.
