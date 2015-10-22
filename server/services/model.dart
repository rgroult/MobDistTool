class User extends Principal {
  final MDTUser dbUser;
  User(MDTUser user ){
    super(user.email);
    dbUser = user;
  }
}