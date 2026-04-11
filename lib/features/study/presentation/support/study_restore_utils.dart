int clampSnapshotIndex(int requestedIndex, int itemCount) {
  if (itemCount <= 0) {
    return 0;
  }

  if (requestedIndex < 0) {
    return 0;
  }

  if (requestedIndex >= itemCount) {
    return itemCount - 1;
  }

  return requestedIndex;
}
