package Asuka;

use strict;
use warnings;
use utf8;

use YAML;
use Data::Dumper;
use Encode qw/encode_utf8 decode_utf8/;
use JSON qw/decode_json/;
use Try::Tiny;

use Api;

my $slack_map = YAML::LoadFile("./yaml/slack_map.yaml");
my $token;

sub parser {
    (my $json, $token) = @_;

    my $content = decode_json(encode_utf8($json));

    warn Dumper $content->{channel};
    if ($content->{type} eq "message") {
        # ircっぽく全チャンネルのメセッジーをリアルタイムで流す
        my $channel_name = _map_name($content->{channel});
        my $user_name = "";
        my $text = "";
        unless ($content->{subtype}) {
            $user_name = _map_name($content->{user});
            $text = $content->{text}; 
           # say sprintf("#%s <%s> %s", $channel_name, $user_name, encode_utf8($text));
        }
        elsif ($content->{subtype} eq "bot_message") {
            $user_name = $content->{username};
            $text = $content->{text};
            #say sprintf("#%s (bot)<%s> %s", $channel_name, encode_utf8($content->{username}), encode_utf8($text));
        }
        elsif ($content->{subtype} eq "message_changed") {
            $user_name = _map_name($content->{message}->{edited}->{user});
            $text = $content->{message}->{text};
            #say sprintf("#%s (changed)<%s> %s", $channel_name, $user_name, encode_utf8($text));
        }
        elsif ($content->{subtype} eq "message_deleted") {
           # say "#$channel_name !message has been deleted!";
        }
        elsif ($content->{subtype} eq "pinned_item") {
            $user_name = _map_name($content->{user});
            #say sprintf("<%s> pined: %s", $user_name, $content->{attachments}->[0]->{fallback});
        }
        elsif ($content->{subtype} eq "file_share" or $content->{subtype} eq "file_comment") {
            #say encode_utf8($content->{text}); 
        }
        else {
            #warn Dumper $content;
        }

        #応答bot
        if ($text =~ 'test_asuka') {
            if ($text =~ m/^\@asuka (.*)/) {
                my $command = $1;
                if ($command eq "help") {
                    #TODO show usage
                    _asuka_send($channel_name, "ごめん、まだ書いてない");
                }
                #TODO add command
                elsif ($command =~ "keyword") { 
                    my $message;
                    try {
                        _asuka_send($channel_name, $message);
                    }
                    catch {
                        _asuka_debug($channel_name, $user_name, $text);
                        _asuka_debug($_);
                    }
                }
                else {
                    # unknown command 
                    _asuka_send($channel_name, $command);
                    _asuka_debug($channel_name, $user_name, $text);
                }
            }
            else {
                #_asuka_send($channel_name, "はい");
                _asuka_send($channel_name, "yes!");
                _asuka_debug($channel_name, $user_name, $text);
            }
        }
    }
}

# send debug message to debug channel 
sub _asuka_debug {
    my $debug_message;
    if (scalar @_ == 1) {
        # debug message
        $debug_message = shift;
    }
    else {
        # where is the message
        my ($channel_name, $user_name, $text) = @_;
        $debug_message = sprintf("%s #%s, mentioned by<%s>:%s", $token, $channel_name, $user_name, $text);
    }
    Api::base({
        mode => "debug",
        text => $debug_message,
    });
}

# response of bot
sub _asuka_send {
    my ($channel, $text) = @_;
    Api::base({
            bot     => "asuka",
            token   => $token,
            channel => $channel,
            text    => $text,
        });
}

# get name from id
sub _map_name {
    my $id = shift;
    if ($id =~ m/^U/ && $slack_map->{$token}->{users}->{$id}) {
        return $slack_map->{$token}->{users}->{$id};
    }
    elsif ($id =~ m/^[CG]/ && $slack_map->{$token}->{channels}->{$id}) {
        return $slack_map->{$token}->{channels}->{$id};
    }
    else {
        my $debug_message = "unknown id <$id>, please update slack map";
        _asuka_debug($debug_message);
    }
}

1;
