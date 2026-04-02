class HubUser {
  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final int credits;
  final int sandboxCredits;
  final String plan;
  final bool emailVerified;
  final String? theme;
  final String? language;

  const HubUser({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
    required this.credits,
    required this.sandboxCredits,
    required this.plan,
    required this.emailVerified,
    this.theme,
    this.language,
  });

  factory HubUser.fromJson(Map<String, dynamic> json) => HubUser(
        id: json['_id'] ?? json['id'] ?? '',
        email: json['email'] ?? '',
        displayName: json['displayName'],
        avatarUrl: json['avatarUrl'],
        credits: json['credits'] ?? 20,
        sandboxCredits: json['sandboxCredits'] ?? 10,
        plan: json['plan'] ?? 'free',
        emailVerified: json['emailVerified'] ?? false,
        theme: json['theme'],
        language: json['language'],
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'email': email,
        'displayName': displayName,
        'avatarUrl': avatarUrl,
        'credits': credits,
        'sandboxCredits': sandboxCredits,
        'plan': plan,
        'emailVerified': emailVerified,
        'theme': theme,
        'language': language,
      };

  HubUser copyWith({
    String? displayName,
    String? avatarUrl,
    int? credits,
    int? sandboxCredits,
    String? plan,
    bool? emailVerified,
    String? theme,
    String? language,
  }) =>
      HubUser(
        id: id,
        email: email,
        displayName: displayName ?? this.displayName,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        credits: credits ?? this.credits,
        sandboxCredits: sandboxCredits ?? this.sandboxCredits,
        plan: plan ?? this.plan,
        emailVerified: emailVerified ?? this.emailVerified,
        theme: theme ?? this.theme,
        language: language ?? this.language,
      );
}
