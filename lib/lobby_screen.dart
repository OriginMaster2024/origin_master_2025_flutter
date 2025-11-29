import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'game_screen.dart';

final BROADCAST_EVENT_GAME_START = 'game_start';

class LobbyScreen extends HookWidget {
  const LobbyScreen({super.key, required this.userID});

  final String userID;

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
        event: BROADCAST_EVENT_GAME_START,
        callback: (payload) {
          final participantIDs = List<String>.from(payload['participants']);
          if (participantIDs.contains(userID)) {
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
        await channel.track({'user_id': userID});
      });

      return () {
        channel.untrack();
        channel.unsubscribe();
        Supabase.instance.client.removeChannel(channel);
      };
    }, []);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('${userIDs.value.length} players waiting'),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Back to Home'),
            ),
            const SizedBox(height: 20),
            if (userIDs.value.length > 2)
              ElevatedButton(
                onPressed: () {
                  final opponentID = userIDs.value.firstWhere(
                    (userID) => userID != userID,
                  );
                  channel.sendBroadcastMessage(
                    event: BROADCAST_EVENT_GAME_START,
                    payload: {
                      'participants': [userID, opponentID],
                      'game_id': Uuid().v4(),
                    },
                  );
                },
                child: Text('Start Game'),
              ),
          ],
        ),
      ),
    );
  }
}
