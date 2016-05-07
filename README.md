#asuka

- Tokio Kichi's realtime assistant chat-bot
- 「asuka」Program's Phase 1

# script/base.pl

- examples:

>  # mini send message

>  % perl script/base.pl --token=slack_token --channel=name --text=your_message

>  # max send message

>  % perl script/base.pl --mode=yaml_mode --bot=yaml_bot --token=slack_token --channel=name --text=your_message --username=bot_name --icon_url=image_url

>  # mini upload file

>  % perl script/base.pl --token=slack_token --channel=name --file=file_path

>  # max upload file

>  % perl script/base.pl --mode=yaml_mode --token=slack_token --channel=name --file=file_path --filename=file_name

- yaml:

>  # .yaml/config.yaml include slack_token

>  # ./yaml/setting.yaml {bot_type} can include username and icon_url

>  # ./yaml/setting.yaml {mode} can include all

>  # usage:

>  % perl script/base.pl --mode=test


# script/client.pl


- a realtime slack web client 

- usage

> % perl script/client.pl --token=test_slack


# script/make_slack_map.pl


- make slak teams of config.yaml channels && users map <id,name>

- usage

> % script/make_slack_map.pl

#Author

nghuubaotrung
