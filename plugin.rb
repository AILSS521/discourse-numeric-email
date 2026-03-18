# frozen_string_literal: true

# name: discourse-numeric-email
# about: Requires email local part (before @) to be numeric only (e.g. QQ number)
# version: 1.2
# authors: LingLong
# url: https://github.com/AILSS521/discourse-numeric-email

enabled_site_setting :numeric_email_enabled

register_site_setting(:numeric_email_enabled, default: true, type: 'bool', client: false)

after_initialize do
  module ::DiscourseNumericEmail
    NUMERIC_REGEX = /\A\d+\z/
  end

  reloadable_patch do |plugin|
    User.class_eval do
      validate :email_local_part_must_be_numeric, on: :create

      def email_local_part_must_be_numeric
        return unless SiteSetting.numeric_email_enabled
        return if email.blank?
        return if id.present? && id < 1  # skip system users
        return if staged?                # skip staged users

        local_part = email.split("@").first
        unless local_part.match?(DiscourseNumericEmail::NUMERIC_REGEX)
          errors.add(:email, I18n.t("discourse_numeric_email.error", default: "必须使用纯数字QQ号注册，不支持英文别名邮箱"))
        end
      end
    end
  end
end
