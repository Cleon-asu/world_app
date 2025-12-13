import 'package:flutter/material.dart';
import 'home_screen.dart';

// Import your other page (replace with your actual page)
// import './other_page.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  // Variables for swipe detection
  double _startX = 0.0;
  bool _isSwiping = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
                childAspectRatio: 0.8,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                return _buildShopItem(index, context);
              },
            ),
          ),
          
          // Swipe detection overlay (invisible)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragStart: (details) {
                _startX = details.globalPosition.dx;
                _isSwiping = true;
              },
              onHorizontalDragUpdate: (details) {
                if (!_isSwiping) return;
                
                // Calculate swipe distance
                final double currentX = details.globalPosition.dx;
                final double deltaX = currentX - _startX;
                
                // Optional: Visual feedback during swipe
                if (deltaX > 50) {
                  // You could add visual feedback here
                }
              },
              onHorizontalDragEnd: (details) {
                if (!_isSwiping) return;
                
                final double endX = details.primaryVelocity ?? 0;
                final double screenWidth = MediaQuery.of(context).size.width;
                
                // Check if it's a right-to-left swipe
                if (endX < -500 || _startX > screenWidth - 50 && endX < 0) {
                  _handleSwipeToNavigate(context);
                }
                
                _isSwiping = false;
                _startX = 0.0;
              },
              onHorizontalDragCancel: () {
                _isSwiping = false;
                _startX = 0.0;
              },
            ),
          ),
          
          // Optional: Visual indicator for swipe
          if (_isSwiping && _startX < 50)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                color: Colors.blue.withValues(alpha: 0.5),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildShopItem(int index, BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: () {
          _handleItemClick(index, context);
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            color: Colors.grey[200],
          ),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12.0),
                      topRight: Radius.circular(12.0),
                    ),
                    color: _getItemColor(index),
                  ),
                  child: Center(
                    child: Icon(
                      _getItemIcon(index),
                      size: 60.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Item ${index + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      '\$${((index + 1) * 9.99).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleItemClick(int index, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Item ${index + 1} selected'),
        duration: const Duration(milliseconds: 500),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleSwipeToNavigate(BuildContext context) {
    // Navigate to another page
    // Replace 'NextPage()' with your actual destination page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(), // Create this page
      ),
    );
  }

  Color _getItemColor(int index) {
    List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.amber,
      Colors.cyan,
      Colors.deepOrange,
      Colors.lime,
    ];
    return colors[index % colors.length];
  }

  IconData _getItemIcon(int index) {
    List<IconData> icons = [
      Icons.rocket,
      Icons.airplanemode_active,
      Icons.directions_car,
      Icons.computer,
      Icons.phone_android,
      Icons.headset,
      Icons.sports_esports,
      Icons.camera_alt,
      Icons.speaker,
      Icons.tv,
      Icons.tablet,
    ];
    return icons[index % icons.length];
  }
}

// Placeholder page for navigation - replace with your actual page
class NextPage extends StatelessWidget {
  const NextPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Page'),
      ),
      body: const Center(
        child: Text(
          'You navigated here by swiping!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}