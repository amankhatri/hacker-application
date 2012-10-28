class FakePaypalUtil
  def self.purchase_link(meeting_registration, invoice, return_url, notify_url)
    return '/main/index'
  end

  def self.validate_confirmation_message(params, paypal_acct)
    return true
  end

  def self.default_notification_url
    return nil
  end

  def self.externalize_invoice_id(invoice_id)
    return invoice_id
  end

  def self.internalize_invoice_id(invoice_id)
    return invoice_id
  end
end
