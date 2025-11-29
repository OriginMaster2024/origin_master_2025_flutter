import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'game_screen.dart';

const _broadcastEventGameStart = 'game_start';

class LobbyScreen extends HookWidget {
  const LobbyScreen({
    super.key,
    required this.myUserID,
    required this.bgmPlayer,
  });

  final String myUserID;
  final AudioPlayer bgmPlayer;

  @override
  Widget build(BuildContext context) {
    final userIDs = useState<List<String>>([]);
    final channel = useMemoized(
      () => Supabase.instance.client.channel(
        'lobby',
        opts: const RealtimeChannelConfig(self: true),
      ),
      [],
    );

    final isStartButtonEnabled = userIDs.value.length >= 2;

    useEffect(() {
      channel.onPresenceJoin((payload) {
        userIDs.value = [
          ...userIDs.value,
          ...payload.newPresences
              .map((presence) => presence.payload['user_id'] as String?)
              .whereType<String>(),
        ];
      });

      channel.onPresenceLeave((payload) {
        userIDs.value = userIDs.value
            .where(
              (userID) => !payload.currentPresences
                  .map((presence) => presence.payload['user_id'] as String?)
                  .whereType<String>()
                  .contains(userID),
            )
            .toList();
      });

      channel.onBroadcast(
        event: _broadcastEventGameStart,
        callback: (payload) {
          final participantIDs = List<String>.from(payload['participants']);
          if (participantIDs.contains(myUserID)) {
            channel.untrack();

            final gameID = payload['game_id'] as String;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GameScreen(gameID: gameID),
              ),
            );
          }
        },
      );

      channel.subscribe((status, error) async {
        if (status != RealtimeSubscribeStatus.subscribed) return;
        await channel.track({'user_id': myUserID});
      });

      return () {
        channel.untrack();
        channel.unsubscribe();
        Supabase.instance.client.removeChannel(channel);
      };
    }, []);

    return Scaffold(
      body: Stack(
        children: [
          // 背景
          Image.asset(
            'assets/start_background.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),

          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isStartButtonEnabled ? 'あいてがみつかりました！' : 'あいてをまっています...',
                  style: TextStyle(fontSize: 20, fontFamily: 'Melonano'),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context, true);
                      },
                      child: Image.asset(
                        'assets/button_back.png',
                        fit: BoxFit.fitWidth,
                        width: 142,
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: isStartButtonEnabled
                          ? () {
                              final opponentID = userIDs.value.firstWhere(
                                (userID) => userID != myUserID,
                                orElse: () => '',
                              );
                              if (opponentID.isEmpty) return;

                              bgmPlayer.stop();

                              channel.sendBroadcastMessage(
                                event: _broadcastEventGameStart,
                                payload: {
                                  'participants': [myUserID, opponentID],
                                  'game_id': Uuid().v4(),
                                },
                              );
                            }
                          : null,
                      child: Image.asset(
                        isStartButtonEnabled
                            ? 'assets/button_start.png'
                            : 'assets/button_start_disabled.png',
                        fit: BoxFit.fitWidth,
                        width: 142,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
