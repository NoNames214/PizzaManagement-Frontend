class ReviewRequest {
  final int pizzaId;
  final int rating;
  final String comment;

  ReviewRequest({
    required this.pizzaId,
    required this.rating,
    required this.comment,
  });

  Map<String, dynamic> toJson() => {
    'pizzaId': pizzaId,
    'rating': rating,
    'comment': comment,
  };
}