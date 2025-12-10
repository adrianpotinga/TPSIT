import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cronometro',
      theme: ThemeData.dark(),
      home: const StopwatchScreen(),
    );
  }
}

class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({Key? key}) : super(key: key);

  @override
  State<StopwatchScreen> createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  int _seconds = 0;
  bool _isRunning = false;
  bool _isPaused = false;
  StreamSubscription? _tickSubscription;
  StreamSubscription? _secondSubscription;

  // Stream 1: genera tick ogni 100ms
  Stream<int> _tickStream() async* {
    int tick = 0;
    while (true) {
      await Future.delayed(const Duration(milliseconds: 100));
      yield tick++;
    }
  }

  // Stream 2: trasforma i tick in secondi (ogni 10 tick = 1 secondo)
  Stream<int> _secondStream(Stream<int> tickStream) async* {
    int tickCount = 0;
    await for (var _ in tickStream) {
      tickCount++;
      if (tickCount >= 10) {
        tickCount = 0;
        yield 1;
      }
    }
  }

  void _startStreams() {
    final tickStream = _tickStream();
    final secondStream = _secondStream(tickStream);
    
    _secondSubscription = secondStream.listen((increment) {
      if (_isRunning && !_isPaused) {
        setState(() {
          _seconds += increment;
        });
      }
    });
  }

  void _stopStreams() {
    _secondSubscription?.cancel();
    _tickSubscription?.cancel();
  }

  void _handleStartStopReset() {
    setState(() {
      if (!_isRunning) {
        // START
        _isRunning = true;
        _isPaused = false;
        _startStreams();
      } else if (!_isPaused) {
        // STOP
        _isRunning = false;
        _stopStreams();
      } else {
        // RESET
        _seconds = 0;
        _isRunning = false;
        _isPaused = false;
        _stopStreams();
      }
    });
  }

  void _handlePauseResume() {
    if (_isRunning) {
      setState(() {
        _isPaused = !_isPaused;
      });
    }
  }

  String _formatTime(int totalSeconds) {
    final mins = totalSeconds ~/ 60;
    final secs = totalSeconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _getButtonLabel() {
    if (!_isRunning) return 'START';
    if (!_isPaused) return 'STOP';
    return 'RESET';
  }

  @override
  void dispose() {
    _stopStreams();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatTime(_seconds),
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: _handleStartStopReset,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: Text(
                      _getButtonLabel(),
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isRunning ? _handlePauseResume : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[700],
                      disabledBackgroundColor: Colors.grey[700],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: Text(
                      _isPaused ? 'RESUME' : 'PAUSE',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}