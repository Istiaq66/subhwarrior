import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:subh_warrior/features/challenge/data/challenge_data.dart';
import 'package:subh_warrior/features/challenge/data/challenge_local_data_source.dart';
import 'package:subh_warrior/features/challenge/data/challenge_remote_data_source.dart';
import 'package:subh_warrior/features/challenge/data/challenge_repository.dart';

class _MockLocal extends Mock implements ChallengeLocalDataSource {}

class _MockRemote extends Mock implements ChallengeRemoteDataSource {}

void main() {
  late _MockLocal local;
  late _MockRemote remote;
  late ChallengeRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(ChallengeData());
  });

  setUp(() {
    local = _MockLocal();
    remote = _MockRemote();
    repository = ChallengeRepositoryImpl(local, remote);
  });

  group('ChallengeRepositoryImpl', () {
    test('load delegates to the local data source', () {
      final data = ChallengeData(userName: 'aisha');
      when(() => local.load()).thenReturn(data);

      expect(repository.load(), same(data));
      verify(() => local.load()).called(1);
      verifyZeroInteractions(remote);
    });

    test('save persists locally first, then syncs to the remote', () async {
      final data = ChallengeData(currentStreak: 3);
      final callOrder = <String>[];
      when(() => local.save(any())).thenAnswer((_) async {
        callOrder.add('local');
      });
      when(() => remote.saveChallenge(any())).thenAnswer((_) async {
        callOrder.add('remote');
      });

      await repository.save(data);

      expect(callOrder, ['local', 'remote']);
      verify(() => local.save(data)).called(1);
      verify(() => remote.saveChallenge(data)).called(1);
    });

    test('saveLocal never touches the remote', () async {
      final data = ChallengeData();
      when(() => local.save(any())).thenAnswer((_) async {});

      await repository.saveLocal(data);

      verify(() => local.save(data)).called(1);
      verifyZeroInteractions(remote);
    });

    test('fetchRemote delegates to the remote data source', () async {
      final data = ChallengeData(userName: 'bilal');
      when(() => remote.fetchChallenge()).thenAnswer((_) async => data);

      expect(await repository.fetchRemote(), same(data));
      verifyZeroInteractions(local);
    });

    test('usernameExists and reserveUsername delegate to the remote', () async {
      when(() => remote.usernameExists('taken', 'me'))
          .thenAnswer((_) async => true);
      when(() => remote.reserveUsername('new', 'old'))
          .thenAnswer((_) async => false);

      expect(await repository.usernameExists('taken', 'me'), isTrue);
      expect(await repository.reserveUsername('new', 'old'), isFalse);
      verifyZeroInteractions(local);
    });
  });
}
