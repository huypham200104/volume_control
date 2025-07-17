import 'package:flutter/material.dart';
import 'package:volume_controller/volume_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Volume Controller',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const MyHomePage(title: 'Volume Controller App'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _navigateToVolumeControl() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VolumeControlScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.grey[900]!,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.volume_up,
              size: 100,
              color: Colors.white,
            ),
            SizedBox(height: 30),
            Text(
              'Volume Controller',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Điều khiển âm lượng thiết bị',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
              ),
            ),
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: _navigateToVolumeControl,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                'Mở điều khiển âm lượng',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VolumeControlScreen extends StatefulWidget {
  const VolumeControlScreen({super.key});

  @override
  _VolumeControlScreenState createState() => _VolumeControlScreenState();
}

class _VolumeControlScreenState extends State<VolumeControlScreen> {
  double _currentVolume = 0.5;
  bool _isMuted = false;
  double _previousVolume = 0.5;

  @override
  void initState() {
    super.initState();
    _initializeVolume();
  }

  Future<void> _initializeVolume() async {
    try {
      double volume = await VolumeController.instance.getVolume();
      setState(() {
        _currentVolume = volume;
        _isMuted = volume == 0;
      });
    } catch (e) {
      print('Error getting volume: $e');
    }
  }

  Future<void> _setVolume(double volume) async {
    try {
      await VolumeController.instance.setVolume(volume);
      setState(() {
        _currentVolume = volume;
        _isMuted = volume == 0;
      });
    } catch (e) {
      print('Error setting volume: $e');
    }
  }

  Future<void> _toggleMute() async {
    try {
      if (_isMuted) {
        await VolumeController.instance.setVolume(_previousVolume);
        setState(() {
          _currentVolume = _previousVolume;
          _isMuted = false;
        });
      } else {
        _previousVolume = _currentVolume;
        await VolumeController.instance.setVolume(0.0);
        setState(() {
          _currentVolume = 0.0;
          _isMuted = true;
        });
      }
    } catch (e) {
      print('Error toggling mute: $e');
    }
  }

  void _increaseVolume() {
    double newVolume = (_currentVolume + 0.1).clamp(0.0, 1.0);
    _setVolume(newVolume);
  }

  void _decreaseVolume() {
    double newVolume = (_currentVolume - 0.1).clamp(0.0, 1.0);
    _setVolume(newVolume);
  }

  IconData _getVolumeIcon() {
    if (_isMuted || _currentVolume == 0) {
      return Icons.volume_off;
    } else if (_currentVolume < 0.3) {
      return Icons.volume_down;
    } else {
      return Icons.volume_up;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Volume Sound',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black,
                    Colors.grey[900]!,
                  ],
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getVolumeIcon(),
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 30),
                  Text(
                    '${(_currentVolume * 100).round()}%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 30),
                  Container(
                    height: 300,
                    width: 80,
                    margin: EdgeInsets.symmetric(horizontal: 50),
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 60,
                          thumbShape:
                          RoundSliderThumbShape(enabledThumbRadius: 20),
                          overlayShape:
                          RoundSliderOverlayShape(overlayRadius: 30),
                          activeTrackColor: Colors.blue,
                          inactiveTrackColor: Colors.grey[700],
                          thumbColor: Colors.white,
                          overlayColor: Colors.blue.withOpacity(0.2),
                        ),
                        child: Slider(
                          value: _currentVolume,
                          min: 0.0,
                          max: 1.0,
                          onChanged: (value) {
                            _setVolume(value);
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: _decreaseVolume,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.remove,
                              color: Colors.white, size: 30),
                        ),
                      ),
                      GestureDetector(
                        onTap: _toggleMute,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: _isMuted ? Colors.red : Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isMuted ? Icons.volume_off : Icons.volume_up,
                            color: Colors.white,
                            size: 35,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _increaseVolume,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            shape: BoxShape.circle,
                          ),
                          child:
                          Icon(Icons.add, color: Colors.white, size: 30),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    _isMuted ? 'Muted' : 'Volume On',
                    style: TextStyle(
                      color: _isMuted ? Colors.red : Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
