# frozen_string_literal: true

# name: discourse-numeric-email
# about: Requires email local part (before @) to be numeric only (e.g. QQ number)
# version: 1.0
# authors: LingLong
# url: https://github.com/example/discourse-numeric-email

after_initialize do
  module ::DiscourseNumericEmail
    NUMERIC_REGEX = /\A\d+\z/
  end

  # Validate email on user creation
  reloadable_patch do |plugin|
    User.class_eval do
      validate :email_local_part_must_be_numeric

      def email_local_part_must_be_numeric
        return if email.blank?
        local_part = email.split("@").first
        unless local_part.match?(DiscourseNumericEmail::NUMERIC_REGEX)
          errors.add(:email, I18n.t("discourse_numeric_email.error", default: "必须使用纯数字QQ号注册，不支持英文别名邮箱"))
        end
      end
    end
  end
end
