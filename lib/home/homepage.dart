import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:new_project_test/app_theme.dart';

import 'account_page.dart';
import 'cart_page.dart';
import 'orders_page.dart';
import 'search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _bannerImages = [
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQcor6VzeTpHcy_0aSE2JfoUdp98LQ54paZ8A&s',
    'https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fimages.labubuwallpaper.com%2FLabubu-Adventure-in-Hidden-Forest%252CLabubu-Desktop-Wallpaper.png&f=1&nofb=1&ipt=a3030ed4e56e81c8389f7553635afe4b1a9a8017d9f5679491fa32fbbd23e7f8',
    'https://howdyhealth.tamu.edu/wp-content/uploads/2023/11/3-easy-ways-to-eat-more-vegetables.webp',
    'https://www.diabetesselfmanagement.com/wp-content/uploads/2023/08/dsm-fruit-nutrition-facts-1-1000x563.jpg',
    'https://tapcom-live.ams3.cdn.digitaloceanspaces.com/media/jihan-khanah/products/788191-Kinza_Drinks6579.jpg',
    'https://i.etsystatic.com/29356732/r/il/34dc4c/5159352621/il_1080xN.5159352621_guwf.jpg',
  ];

  final cart = <Map<String, dynamic>>[];
  int _selectedIndex = 0;

  Stream<QuerySnapshot<Map<String, dynamic>>> get _productsStream {
    return FirebaseFirestore.instance.collection('products').snapshots();
  }

  void _openSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchPage(cart: cart)),
    );
  }

  void _openCart() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CartPage(cart: cart)),
    );
  }

  void _addToCart(Map<String, dynamic> product, int quantity) {
    final index = cart.indexWhere((item) => item['id'] == product['id']);

    setState(() {
      if (index == -1) {
        cart.add({...product, 'quantity': quantity});
      } else {
        cart[index]['quantity'] = (cart[index]['quantity'] ?? 1) + quantity;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$quantity ${product['name']} added to cart')),
    );
  }

  void _showProductSheet(Map<String, dynamic> product) {
    var quantity = 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final total = _priceOf(product) * quantity;

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  18,
                  12,
                  18,
                  MediaQuery.of(context).viewInsets.bottom + 18,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: _sheetHandle()),
                    const SizedBox(height: 16),
                    _productImage(product['image'], height: 180),
                    const SizedBox(height: 16),
                    Text(
                      product['name'],
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '\$${product['price']}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      product['description'],
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        IconButton.filledTonal(
                          onPressed: quantity == 1
                              ? null
                              : () => setSheetState(() => quantity--),
                          icon: const Icon(Icons.remove),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Text(
                            '$quantity',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton.filledTonal(
                          onPressed: () => setSheetState(() => quantity++),
                          icon: const Icon(Icons.add),
                        ),
                        const Spacer(),
                        Text(
                          'Total: \$${total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _addToCart(product, quantity);
                        },
                        icon: const Icon(Icons.shopping_cart_outlined),
                        label: const Text('Add to cart'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  double _priceOf(Map<String, dynamic> product) {
    final price = product['price'];
    if (price is num) return price.toDouble();
    return double.tryParse(price.toString()) ?? 0;
  }

  Map<String, dynamic> _productFromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    return {
      'id': doc.id,
      'name': data['name'] ?? '',
      'price': data['price'] ?? 0,
      'description': data['description'] ?? '',
      'image': data['imageUrl'] ?? data['image'] ?? '',
      'category': data['category'] ?? '',
    };
  }

  Widget _homeTab() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _productsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Could not load products: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final products =
            snapshot.data?.docs
                .where((doc) => doc.data()['soldOut'] != true)
                .map(_productFromDoc)
                .toList() ??
            [];

        return SingleChildScrollView(
          child: Column(
            children: [
              _welcomeHeader(products.length),
              _bannerSlider(),
              _productGrid(products),
            ],
          ),
        );
      },
    );
  }

  Widget _bannerSlider() {
    return CarouselSlider.builder(
      itemCount: _bannerImages.length,
      options: CarouselOptions(
        height: 185,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 0.92,
        autoPlayInterval: const Duration(seconds: 3),
      ),
      itemBuilder: (context, index, realIndex) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                _bannerImages[index],
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Icon(Icons.image_not_supported));
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _welcomeHeader(int productCount) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.pomegranate, AppColors.coral],
        ),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fresh picks today',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Browse colorful groceries, drinks, and gifts in one place.',
                  style: TextStyle(color: Colors.white, height: 1.35),
                ),
              ],
            ),
          ),
          Container(
            width: 68,
            height: 68,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$productCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Text(
                  'items',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _productGrid(List<Map<String, dynamic>> products) {
    if (products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: Text('No products available')),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.local_mall_outlined, color: AppColors.pomegranate),
              SizedBox(width: 8),
              Text(
                'Products',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            itemBuilder: (context, index) => _productCard(products[index]),
          ),
        ],
      ),
    );
  }

  Widget _productCard(Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () => _showProductSheet(product),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: softPanelDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _productImage(product['image'], height: 96),
            const SizedBox(height: 8),
            Text(
              product['name'],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              product['description'],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '\$${product['price']}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton.filled(
                  tooltip: 'Add',
                  onPressed: () => _showProductSheet(product),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _productImage(dynamic imageUrl, {required double height}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imageUrl.toString(),
        width: double.infinity,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: height,
            alignment: Alignment.center,
            color: Colors.grey.shade200,
            child: const Icon(Icons.image_not_supported),
          );
        },
      ),
    );
  }

  Widget _sheetHandle() {
    return Container(
      width: 44,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [_homeTab(), const OrdersPage(), const AccountPage()];

    return Scaffold(
      appBar: AppBar(
        title: Text(['Home', 'Orders', 'Account'][_selectedIndex]),
        actions: [
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search),
            onPressed: _openSearch,
          ),
          IconButton(
            tooltip: 'Cart',
            icon: Badge(
              isLabelVisible: cart.isNotEmpty,
              label: Text('${cart.length}'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            onPressed: _openCart,
          ),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }
}
