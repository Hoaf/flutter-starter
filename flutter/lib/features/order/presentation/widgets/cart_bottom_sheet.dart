import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_demo/features/order/presentation/cubit/cart_cubit.dart';
import 'package:flutter_demo/features/order/presentation/cubit/cart_state.dart';
import 'package:flutter_demo/features/order/presentation/cubit/order_cubit.dart';
import 'package:flutter_demo/features/order/presentation/cubit/order_state.dart';
import 'package:flutter_demo/presentation/config/app_colors.dart';
import 'package:flutter_demo/presentation/config/app_font_sizes.dart';

class CartBottomSheet extends StatelessWidget {
  const CartBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<CartCubit>(),
        child: BlocProvider.value(
          value: context.read<OrderCubit>(),
          child: const CartBottomSheet(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderCubit, OrderState>(
      listener: (context, state) {
        if (state is OrderSuccess) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order placed successfully!'),
              backgroundColor: AppColors.green,
            ),
          );
        } else if (state is OrderError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.red,
            ),
          );
        }
      },
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                _buildHandle(),
                _buildHeader(context),
                const Divider(height: 1),
                Expanded(
                  child: BlocBuilder<CartCubit, CartState>(
                    builder: (context, state) =>
                        _buildBody(context, state, scrollController),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 10, bottom: 6),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.gray,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 8, 12),
      child: Row(
        children: [
          BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              final count =
                  state is CartLoaded ? state.totalItemCount : 0;
              return Text(
                'Cart ($count ${count == 1 ? 'item' : 'items'})',
                style: const TextStyle(
                  fontSize: AppFontSizes.fs_16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.shark,
                  fontFamily: 'Ubuntu',
                ),
              );
            },
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.paleSky),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, CartState state, ScrollController scrollController) {
    if (state is CartLoaded && state.items.isNotEmpty) {
      return Column(
        children: [
          Expanded(
            child: ListView.separated(
              controller: scrollController,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: state.items.length,
              separatorBuilder: (_, __) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final item = state.items[index];
                return Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.cyanLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.shopping_bag_outlined,
                          color: AppColors.cyan, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: AppFontSizes.fs_14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.shark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.formattedPrice,
                            style: const TextStyle(
                              fontSize: AppFontSizes.fs_12,
                              color: AppColors.paleSky,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        _QtyButton(
                          icon: Icons.remove,
                          onTap: () => context
                              .read<CartCubit>()
                              .removeItem(item.productId),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '${item.quantity}',
                            style: const TextStyle(
                              fontSize: AppFontSizes.fs_14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.shark,
                            ),
                          ),
                        ),
                        _QtyButton(
                          icon: Icons.add,
                          onTap: () => context
                              .read<CartCubit>()
                              .addItem(item.copyWith(quantity: 1)),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          _buildFooter(context, state),
        ],
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.shopping_cart_outlined,
              size: 64, color: AppColors.gray),
          const SizedBox(height: 12),
          const Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: AppFontSizes.fs_14,
              color: AppColors.paleSky,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, CartLoaded state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: AppFontSizes.fs_15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.shark,
                ),
              ),
              Text(
                '\$${state.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: AppFontSizes.fs_16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.cyan,
                  fontFamily: 'Ubuntu',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          BlocBuilder<OrderCubit, OrderState>(
            builder: (context, orderState) {
              final isPlacing = orderState is OrderPlacing;
              return ElevatedButton(
                onPressed: isPlacing
                    ? null
                    : () => context.read<OrderCubit>().placeOrder(
                          items: state.items,
                          totalAmount: state.totalAmount,
                        ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cyan,
                  foregroundColor: AppColors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isPlacing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : const Text(
                        'Place Order',
                        style: TextStyle(
                          fontSize: AppFontSizes.fs_15,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Ubuntu',
                        ),
                      ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          color: AppColors.cyanLight,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: AppColors.cyan),
      ),
    );
  }
}
