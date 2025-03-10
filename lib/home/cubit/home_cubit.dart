import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:restaurant_repository/restaurant_repository.dart';
import 'package:user_repository/user_repository.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required RestaurantRepository restaurantRepository,
    required UserRepository userRepository,
  })  : _restaurantRepository = restaurantRepository,
        _userRepository = userRepository,
        super(const HomeState()) {
    _restaurantsSubscription =
        _restaurantRepository.restaurants.listen(_onRestaurantsLoaded);
    _favoriteRestaurantsSubscription =
        _userRepository.favorites.listen(_onFavoritesLoaded);
  }
  late StreamSubscription<List<Restaurant>> _restaurantsSubscription;
  final RestaurantRepository _restaurantRepository;
  late StreamSubscription<List<Restaurant>> _favoriteRestaurantsSubscription;
  final UserRepository _userRepository;
  @override
  Future<void> close() {
    _restaurantsSubscription.cancel();
    _favoriteRestaurantsSubscription.cancel();
    return super.close();
  }

  Future<void> fetchRestaurants() async {
    if (state.allRestaurantsStatus == HomeListStatus.completed) return;
    try {
      if (state.allRestaurantsStatus != HomeListStatus.initial) {
        emit(state.copyWith(allRestaurantsStatus: HomeListStatus.loading));
      }
      await _restaurantRepository.getRestaurants();
    } on RestaurantHttpRequestFailure catch (_) {
      emit(state.copyWith(allRestaurantsStatus: HomeListStatus.error));
    } catch (_) {
      emit(state.copyWith(allRestaurantsStatus: HomeListStatus.error));
    }
  }

  void _onRestaurantsLoaded(List<Restaurant> restaurants) {
    if (restaurants.length == state.allRestaurants.length) {
      emit(state.copyWith(allRestaurantsStatus: HomeListStatus.completed));
    } else {
      emit(
        state.copyWith(
          allRestaurantsStatus: HomeListStatus.loaded,
          allRestaurants: restaurants,
        ),
      );
    }
  }

  void _onFavoritesLoaded(List<Restaurant> restaurants) {
    if (restaurants.length == state.allRestaurants.length) {
      emit(state.copyWith(favoritesStatus: HomeListStatus.completed));
    } else {
      emit(
        state.copyWith(
          favoritesStatus: HomeListStatus.loaded,
          favorites: restaurants,
        ),
      );
    }
  }
}
