import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_demo/di/service_locator.dart';
import 'package:flutter_demo/features/order/presentation/cubit/cart_cubit.dart';
import 'package:flutter_demo/features/order/presentation/cubit/order_cubit.dart';
import 'package:flutter_demo/features/order/presentation/cubit/order_state.dart';
import 'package:flutter_demo/features/order/presentation/pages/orders_tab.dart';
import 'package:flutter_demo/presentation/config/app_colors.dart';
import 'package:flutter_demo/presentation/config/app_font_sizes.dart';
import 'package:flutter_demo/features/product/presentation/cubit/product_cubit.dart';
import 'package:flutter_demo/features/product/presentation/pages/discover_tab.dart';
import 'package:flutter_demo/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:flutter_demo/features/profile/presentation/pages/profile_tab.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    DiscoverTab(),
    OrdersTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProductCubit>(create: (_) => getIt<ProductCubit>()),
        BlocProvider<ProfileCubit>(create: (_) => getIt<ProfileCubit>()),
        BlocProvider<CartCubit>(create: (_) => getIt<CartCubit>()),
        BlocProvider<OrderCubit>(create: (_) => getIt<OrderCubit>()),
      ],
      child: BlocListener<OrderCubit, OrderState>(
        listener: (context, state) {
          if (state is OrderSuccess) {
            setState(() => _currentIndex = 1);
            context.read<OrderCubit>().loadOrders();
            context.read<CartCubit>().loadCart();
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.lightGrey,
          body: IndexedStack(
            index: _currentIndex,
            children: _tabs,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            backgroundColor: AppColors.white,
            selectedItemColor: AppColors.cyan,
            unselectedItemColor: AppColors.paleSky,
            selectedLabelStyle: const TextStyle(
              fontSize: AppFontSizes.fs_10,
              fontWeight: FontWeight.w600,
              fontFamily: 'Ubuntu',
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: AppFontSizes.fs_10,
              fontWeight: FontWeight.w500,
              fontFamily: 'Ubuntu',
            ),
            type: BottomNavigationBarType.fixed,
            elevation: 8,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined),
                activeIcon: Icon(Icons.receipt_long),
                label: 'Orders',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
