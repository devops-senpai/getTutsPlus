getTutsPlus
===========

Rip a tutsplus course with your cookie.

Requirements
===========

brew install wget
brew install exiftool
brew tap homebrew/dupes
brew install tidy

Usage
===========

```
./getTutsPlus.sh path/to/cookie [coursename-from-url]
```
eg. url: https://tutsplus.com/course/riding-ruby-on-rails/ 
coursename would be "riding-ruby-on-rails"

Install Chrome extension [cookie.txt export](https://chrome.google.com/webstore/detail/cookietxt-export/lopabhfecdfhgogdbojmaicoicjekelh "Chrome Extension: cookie.txt export")

To get cookie log into tutsplus with your premium account then copy cookie.txt export ouput plugin to a file.
