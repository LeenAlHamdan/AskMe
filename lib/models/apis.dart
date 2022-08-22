class APIs {
  static const host = 'https://2ajv18lh90.execute-api.us-east-2.amazonaws.com';

  static const environment = 'dev';

  static const name = 'name';
  static const limit = 'limit';
  static const offset = 'offset';

  //Authentication
  static const signIn = 'auth/public/login';
  static const signUp = 'auth/public/sign-up';
  static const restPasswordWithCode = 'auth/public/reset-password';
  static const requestPasswordCode = 'auth/public/request-password-reset-code';
  static const changePassword = 'auth/change-password';

  //user
  static const user = 'user';

  static const profileImage = 'profile-image';
  static const profileData = 'my-profile';
  static const designers = 'user/designers';
  static const userFavorites = 'user/favorites';

  //field
  static const field = 'user/field';
  static const fieldGet = 'user/public/field';

  //specialization
  static const specialization = 'user/specialization';
  static const specializationGet = 'user/public/specialization';

  //Specialist
  static const specialist = 'user/specialist';
  static const rateSpecialist = 'user/specialist/rate';
  static const specialistGet = 'user/public/specialist';

  //Questions
  static const question = 'question';
  static const questionGet = 'question/public';

  //Answers
  static const answer = 'question/answer';
  static const answerIsSolution = 'question/answer/is-solution';
  static const answerGet = 'question/public/answer';
  static const questionId = 'questionId';

  //consultancy
  static const messagesGet = 'chat/message';
  static const unseenMessagesGet = 'chat/message/unseen';
  static const consultancyGet = 'chat/consultancy';
}
