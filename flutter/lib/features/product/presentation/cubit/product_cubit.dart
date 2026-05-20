import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/product/domain/usecases/get_products_usecase.dart';
import 'package:flutter_demo/features/product/presentation/cubit/product_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class ProductCubit extends Cubit<ProductState> {
  final GetProductsUseCase _useCase;

  ProductCubit(this._useCase) : super(const ProductInitial());

  Future<void> loadProducts() async {
    emit(const ProductLoading());
    final result = await _useCase();
    switch (result) {
      case Success(:final value):
        emit(ProductLoaded(products: value));
      case Failure(:final exception):
        emit(ProductError(message: exception));
    }
  }
}
