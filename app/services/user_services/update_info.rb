module UserServices
  class UpdateInfoError < StandardError; end

  class UpdateInfo < BaseService
    COGNITO_MAPPING = {
      "sub" => :uuid,
      "username" => :user_name,
      "given_name" => :first_name,
      "family_name" => :last_name,
      "email" => :email,
      "phone_number" => :phone,
      "custom:hubspot_contact_id" => :hs_contact_id,
    }.freeze

    def call
      assign_cognito_info
      assign_pennylane_info if user.pl_client_id.blank?

      add_errors(**user.errors) unless user.valid?
      user.save
    end

    private
      def assign_cognito_info
        params.each do |key, value|
          mapping_attr = COGNITO_MAPPING[key]

          next unless mapping_attr.present? && user.respond_to?(mapping_attr)

          user.send("#{mapping_attr}=", value)
        end
      end

      def assign_pennylane_info
        return unless related_quotes.any?

        pennylane = Crm::Pennylane.new
        pl_clients = related_quotes.map { |quote| pennylane.get_client_by_reference(quote.reference) }

        raise UpdateInfoError, "Match multiple Pennylane clients, should have only one" if pl_clients.size > 1

        user.pl_client_id = pl_clients.first[:source_id]
      end

      def related_quotes
        @related_quotes ||= Crm::Hubspot.new.get_quotes_from_contact_id(user.hs_contact_id)
      end
  end
end
