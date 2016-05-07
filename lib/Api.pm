package Api;
use strict;
use warnings;
use utf8;

use YAML;
use Encode qw/decode_utf8/;
use JSON qw/decode_json/;
use Furl;
use HTTP::Request::Common;
use Getopt::Long;
use Data::Dumper;

my $config = YAML::LoadFile("./yaml/config.yaml");
my $setting = YAML::LoadFile("./yaml/setting.yaml");

sub base {
    my $opts = shift;

    #mode
    if ($opts->{mode}) {
        die "no mode $opts->{mode}" unless ($setting->{mode} and $setting->{mode}->{$opts->{mode}});
        my $mode = $setting->{mode}->{$opts->{mode}};
        while (my ($key, $value) = each %$mode) {
            $opts->{$key} //= $value;
        }
    }

    #bot
    if ($opts->{bot} and $setting->{bot_type}) {
        my $bot = $setting->{bot_type}->{$opts->{bot}};
        die "no bot $opts->{bot}" unless $bot;
        $opts->{username} //= $bot->{username};
        unless (ref $bot->{icon_url} eq "ARRAY") {
            $opts->{icon_url} //= $bot->{icon_url};
        }   
        else {
            my $randam = rand(scalar @{$bot->{icon_url}}); 
            $opts->{icon_url} //= $bot->{icon_url}->[int($randam)];
        }   
    } 

    #opts must have token and channel
    die "no token" unless $opts->{token};
    die "no channel" unless $opts->{channel};
    die "can't get token $opts->{token}" unless ($config->{slack_token} and $config->{slack_token}->{$opts->{token}});

    die "do nothing" unless $opts->{file} or $opts->{text};
    _upload_file($opts) if $opts->{file};
    _chat_postMessage($opts) if $opts->{text};
}

# send message
sub _chat_postMessage {
    my $opts = shift;

    die "no text" unless $opts->{text};
    my $post = {
        token   => $config->{slack_token}->{$opts->{token}},
        channel => "#" . $opts->{channel},
        text    => decode_utf8($opts->{text}),
    };

    $post->{username} = $opts->{username} if $opts->{username};
    $post->{icon_url} = $opts->{icon_url} if $opts->{icon_url};

    my $req = POST 'https://slack.com/api/chat.postMessage',
        'Content' => [
            $post
        ];
    my $res = Furl->new->request($req);
}

# get channel id by channel name
sub _get_channel_id {
    my ($channel, $token) = @_; 

    my $res_channels = Furl->new->post('https://slack.com/api/channels.list', [], +{ token => $token });
    my %channels  = map { sprintf('#%s', $_->{name}) => $_->{id} } @{decode_json($res_channels->content)->{channels}};
    my $channel_id = $channels{$channel};
    return $channel_id if $channel_id;

    my $res_groups = Furl->new->post('https://slack.com/api/groups.list', [], +{ token => $token });
    my %groups  = map { sprintf('#%s', $_->{name}) => $_->{id} } @{decode_json($res_groups->content)->{groups}};
    $channel_id = $groups{$channel};
    return $channel_id if $channel_id;

    die "can't find channel id";
}

# upload file
sub _upload_file {
    my $opts = shift;

    my $channel_id = _get_channel_id($opts->{channel}, $config->{slack_token}->{$opts->{token}});

    my $post = {
        token    => $config->{slack_token}->{$opts->{token}},
        channels => $channel_id,
        filename => $opts->{filename},
        file     => [$opts->{file}],
    };
    #warn Dumper $post;

    my $req = POST ('https://slack.com/api/files.upload',
        'Content-Type' => 'form-data',
        Content      => [
            %$post,
        ]);
    my $res = Furl->new->request($req);
    #warn $res->content;
}

# get rtm socket
sub get_rtm_socket {
    my $token = shift;
   # warn Dumper $config->{slack_token}->{$token};
    die "can't get token $token" unless ($config->{slack_token} and $config->{slack_token}->{$token});

    my $res = Furl->new->post('https://slack.com/api/rtm.start', [], +{ token => $config->{slack_token}->{$token} });
   # warn Dumper $res->content;
    die "response fail" unless decode_json($res->content)->{ok};
    return decode_json($res->content)->{url};
}

# make slack map
sub make_slack_map {
    my %slack_map;
    while (my ($key, $value) = each %{$config->{slack_token}}) {
        my $res_channels = Furl->new->post('https://slack.com/api/channels.list', [], +{ token => $value });
        my $res_groups = Furl->new->post('https://slack.com/api/groups.list', [], +{ token => $value });
        my %channels  = map { $_->{id} => $_->{name} } (@{decode_json($res_channels->content)->{channels}}, @{decode_json($res_groups->content)->{groups}});
        my $res_users = Furl->new->post('https://slack.com/api/users.list', [], +{ token => $value });
        my %users = map { $_->{id} => $_->{name} } @{decode_json($res_users->content)->{members}};
        $slack_map{$key} = {
            channels => \%channels,
            users => \%users,
        };
    }
   # warn Dumper \%slack_map; 
    YAML::DumpFile("yaml/slack_map.yaml",\%slack_map );
    #say "make slack map success";
}

1;
