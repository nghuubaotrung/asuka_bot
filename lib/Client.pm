package Client;
use strict;
use warnings;
use utf8;

use IO::Socket;
use Protocol::WebSocket::Client;
use Data::Dumper;

use Asuka;

sub connect {
    my ($url, $token) = @_;

    my ($host) = $url =~ m{wss://(.+)/websocket};
    my $socket = IO::Socket::SSL->new(PeerHost => $host, PeerPort => 443);
    $socket->blocking(0);
    $socket->connect;

    warn Dumper "connecting...";
    my $ws_client = Protocol::WebSocket::Client->new(url => $url);
    $ws_client->on(read => sub {
        my ($client, $buffer) = @_;
        Asuka::parser($buffer, $token);
    });
    $ws_client->on(write => sub {
        my ($client, $buffer) = @_;
        syswrite $socket, $buffer;
    });
    $ws_client->on(connect => sub {
        print 'on_connect';
    });
    $ws_client->on(error => sub {
        my ($client, $error) = @_;
        warn Dumper $error;
        print 'on_error: ', $error;
    });
    $ws_client->connect;

    my $i = 0;
    while (1) {
        my $data = '';
        while (my $line = readline $socket) {
            my $a = $line;
            $a =~ s/(.)/sprintf "%X", ord($1)/eg;
            $data .= $line;
            last if $line eq "\r\n";
        }
        $ws_client->read($data) if $data;
        if ($i++ % 30 == 0) {
            # 定期的にpingしないと接続が切れる
            $ws_client->write('{"type": "ping"}');
        }
        sleep 1;
    }
}

1;

__END__
