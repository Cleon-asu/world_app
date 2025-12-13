import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:world_app/data/currency_database.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  // Variables for swipe detection
  double _startX = 0.0;
  bool _isSwiping = false;
  int _currencyValue = 0;
  int _worldLevel = 1;

  @override
  void initState() {
    super.initState();
    _loadCurrencyValue();
    _loadWorldLevel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                const Icon(
                  Icons.star_border_outlined,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  '$_currencyValue',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
        elevation: 2,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/cosmic_background.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(
                alpha: 0.4,
              ), // Adjust opacity (0.0 to 1.0)
              BlendMode.darken,
            ),
          ),
        ),
        child: Stack(
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
                itemCount: 4,
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
      ),
    );
  }

  Widget _buildShopItem(int index, BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
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
                    color: Colors.black,
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 100.0,
                      height: 100.0,
                      child: Image.asset(
                        _getItemImagePath(index),
                        fit: BoxFit.contain,
                      ),
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
                      '\$${((index + 1) * 10).toStringAsFixed(2)}',
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
    if (_currencyValue >= (index + 1) * 10) {
      int newValue = _currencyValue - ((index + 1) * 10);
      _updateCurrency(newValue);

      _updateWorldLevel(index + 1);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item purchased successfully'),
          duration: const Duration(milliseconds: 500),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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

  void _loadCurrencyValue() {
    final value = CurrencyStorage.getCurrency();
    setState(() {
      _currencyValue = value;
    });
  }

  Future<void> _updateCurrency(int newValue) async {
    await CurrencyStorage.setCurrency(newValue);

    // Show snackbar feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Currency updated!'),
        duration: const Duration(milliseconds: 800),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );

    setState(() {
      _currencyValue = newValue;
    });
  }

  void _loadWorldLevel() {
    final value = CurrencyStorage.getWorldLevel();
    setState(() {
      _worldLevel = value;
    });
  }

  Future<void> _updateWorldLevel(int newValue) async {
    await CurrencyStorage.setWorldLevel(newValue);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('World level changed!'),
        duration: const Duration(milliseconds: 800),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _getItemImagePath(int index) {
    List<String> imagePaths = [
      'assets/images/world_image_1.JPG',
      'assets/images/world_image_2.JPG',
      'assets/images/world_image_3.JPG',
      'assets/images/world_image_4.JPG',
    ];
    return imagePaths[index];
  }
}
