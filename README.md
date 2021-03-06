[![Gem Version](https://badge.fury.io/rb/fde-slack-notification.svg)](https://badge.fury.io/rb/fde-slack-notification)
[![Build Status](https://travis-ci.org/fashion-data-exchange/slack-notification.svg?branch=master)](https://travis-ci.org/fashion-data-exchange/slack-notification)
[![Code Climate](https://codeclimate.com/github/fashion-data-exchange/slack-notification/badges/gpa.svg)](https://codeclimate.com/github/fashion-data-exchange/slack-notification)

# Slack::Notification
## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fde-slack-notification'
```
And then execute:

```bash
bundle install
```

### Authorization

The client requires the following environment variables to be set:

```bash
SLACK_FD_WEBHOOK_URL =  'https://hooks.slack.com' //Your slack hook here
```

### Usage

In order to send a notification to slack, you can write a method like the following.

```ruby
  def notifier
    message = FDE::Slack::Message.new(
      'your message title',
      fields,
      {
        title_link:
          {
            title: 'title',
            title_link: 'title',
            thumb_url: 'author_icon'
          },
        footer: FDE::Slack::Footer.new('footer_text).to_h
      }
    )

    message.info(channel)
  end
  
  
  # create a hash for your required fields
    def fields
      [
        {
          title: 'Field 1',
          value: 'value 1',
          short: false
        },
        {
          title: 'Field 2',
          value: 'value 2',
          short: false
        },  
      ]
    end

```

### Configuration

To set the hook_url value, you may have an initializer under `config/initializers` like this

```ruby
require "slack/notification"

FDE::Slack::Notification.configure do |config|
  config.webhook = 'hook_url'
end
```


### Styling

Any of these methods can be used to get the following colored sidebars

1. message.info(channel) # BLUE
2. message.success(channel) # GREEN
3. message.error(channel) # RED
4. message.warning(channel) # YELLOW
