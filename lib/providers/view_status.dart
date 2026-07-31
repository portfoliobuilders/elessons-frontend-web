/// Shared UI state machine for every provider: idle → loading → success/error.
enum ViewStatus {
  idle,
  loading,
  success,
  error;

  bool get isLoading => this == ViewStatus.loading;
  bool get isError => this == ViewStatus.error;
  bool get isSuccess => this == ViewStatus.success;
  bool get isIdle => this == ViewStatus.idle;
}
