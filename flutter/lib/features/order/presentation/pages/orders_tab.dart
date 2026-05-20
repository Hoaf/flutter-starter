import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_demo/features/order/domain/entities/order_entity.dart';
import 'package:flutter_demo/features/order/presentation/cubit/order_cubit.dart';
import 'package:flutter_demo/features/order/presentation/cubit/order_state.dart';
import 'package:flutter_demo/presentation/config/app_colors.dart';
import 'package:flutter_demo/presentation/config/app_font_sizes.dart';

class OrdersTab extends StatefulWidget {
  const OrdersTab({super.key});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  @override
  void initState() {
    super.initState();
    context.read<OrderCubit>().loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Text(
              'My Orders',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.shark,
                fontFamily: 'Ubuntu',
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<OrderCubit, OrderState>(
              builder: (context, state) {
                if (state is OrderLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.cyan),
                  );
                }

                if (state is OrderError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.wifi_off_outlined,
                            size: 48, color: AppColors.paleSky),
                        const SizedBox(height: 12),
                        Text(
                          state.message,
                          style: const TextStyle(
                            fontSize: AppFontSizes.fs_14,
                            color: AppColors.paleSky,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: () =>
                              context.read<OrderCubit>().loadOrders(),
                          icon: const Icon(Icons.refresh,
                              color: AppColors.cyan),
                          label: const Text(
                            'Retry',
                            style: TextStyle(color: AppColors.cyan),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (state is OrderLoaded) {
                  if (state.orders.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.receipt_long_outlined,
                              size: 64, color: AppColors.gray),
                          const SizedBox(height: 12),
                          const Text(
                            'No orders yet',
                            style: TextStyle(
                              fontSize: AppFontSizes.fs_14,
                              color: AppColors.paleSky,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    itemCount: state.orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _OrderCard(order: state.orders[index]),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderEntity order;
  const _OrderCard({required this.order});

  Color _statusColor(String status) => switch (status) {
        'shipped' => AppColors.blue,
        'delivered' => AppColors.green,
        'cancelled' => AppColors.red,
        _ => AppColors.paleSky,
      };

  String _formattedDate(String createdAt) {
    try {
      final dt = DateTime.parse(createdAt).toLocal();
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return createdAt;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(order.status);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'ORDER #ORD-${order.id}',
                style: const TextStyle(
                  fontSize: AppFontSizes.fs_14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.shark,
                  fontFamily: 'Ubuntu',
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: AppFontSizes.fs_12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '\$${order.totalAmount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: AppFontSizes.fs_16,
              fontWeight: FontWeight.bold,
              color: AppColors.cyan,
              fontFamily: 'Ubuntu',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Placed on ${_formattedDate(order.createdAt)}',
            style: const TextStyle(
              fontSize: AppFontSizes.fs_12,
              color: AppColors.paleSky,
            ),
          ),
          if (order.status == 'delivered') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                _ActionButton(label: 'Reorder', onTap: () {}),
                const SizedBox(width: 8),
                _ActionButton(label: 'View Details', onTap: () {}),
              ],
            ),
          ] else if (order.status == 'shipped') ...[
            const SizedBox(height: 12),
            _ActionButton(label: 'Track Order', onTap: () {}),
          ],
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ActionButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.cyan,
        side: const BorderSide(color: AppColors.cyan),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: AppFontSizes.fs_12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
