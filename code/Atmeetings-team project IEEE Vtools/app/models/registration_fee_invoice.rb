# This class represents an invoice for a meeting's registration fee. An instance
# of this class is created at registration time whether a member pays the fee
# during registration using Paypal, or the member chooses to pay the fee in
# person at the meeting (if allowed). The invoice_id property holds a unique
# locally generated identifier for the invoice instance. It is used to locate
# the invoice when payment notification is received from Paypal (note: it is
# not a foreign key, despite the appearance of the name). The transaction_id
# property holds a unique Paypal identifier for the payment of the invoice (also
# not a foreign key). The status property represents the payment status of the
# invoice. There are four valid states:
#
#     WAITING    - The member chose online payment at registration time and was
#                  redirected to Paypal but final confirmation has not yet been
#                  received from Paypal.
#     PAID       - Successful payment confirmation was received from Paypal.
#     DENIED     - A notification that payment was not successfully conmpleted
#                  was received from Paypal.
#     AT_MEETING - The member chose to pay in person at the meeting instead of
#                  using Paypal for online payment.
#
# The allowed transitions are from WAITING to either PAID or DENIED (to cover
# cases where payment completes successfully through Paypal or fails) or from
# either AT_MEETING or DENIED to WAITING (to cover cases where member originally
# chose to pay at the meeting, but would now like to go ahead and pay online, or
# when a previous payment attempt failed and the member would like to try
# again). For convience, do not set the status property directly, but use the
# provided state transition methods. Also, use provided builder methods for
# instantiation to ensure valid intial status and invoice_id, rather than just
# using 'new()' method.
class RegistrationFeeInvoice < ActiveRecord::Base

  WAITING = 'waiting'
  PAID = 'paid'
  DENIED = 'denied'
  AT_MEETING = 'at_meeting'

  has_many :meeting_registrations

  validates_presence_of :price
  validates_presence_of :currency
  validates_presence_of :invoice_id
  validates_numericality_of :price, :greater_than_or_equal_to => 0
  validates_uniqueness_of :invoice_id
  validates_uniqueness_of :transaction_id, :allow_nil => true
  validates_inclusion_of :status,
    :in => [WAITING, PAID, DENIED, AT_MEETING]

  # Convenience methods
  def paid?
    self.status == PAID
  end
  def denied?
    self.status == DENIED
  end
  def waiting?
    self.status == WAITING
  end
  def pay_at_meeting?
    self.status == AT_MEETING
  end
  def payable?
    # Member can try to pay (or try again) if previously chose to pay in
    # person or if previous payment attempt failed.
    self.pay_at_meeting? or self.denied?
  end

  # State transitions
  def mark_paid
    unless self.status == WAITING
      raise "invalid attempt to change status from '#{self.status}' to " +
        "'paid' for invoice '#{self.invoice_id}'"
    end
    self.status = PAID
  end

  def mark_denied
    unless self.status == WAITING
      raise "invalid attempt to change status from '#{self.status}' to " +
        "'denied' for invoice '#{self.invoice_id}'"
    end
    self.status = DENIED
  end

  def mark_waiting
    # Allow member to try paying online if previously chose to pay in person
    # or if previous attempt failed.
    unless self.status == AT_MEETING or self.status == DENIED
      raise "invalid attempt to change status from '#{self.status}' to " +
        "'waiting' for invoice '#{self.invoice_id}'"
    end
    self.status = WAITING
  end

  # Simple builder methods
  def self.create_online_invoice(price, currency)
    RegistrationFeeInvoice.new(:status => WAITING,
      :price => price, :currency => currency,
      :invoice_id => RegistrationFeeInvoice.generate_invoice_id)
  end

  def self.create_at_meeting_invoice(price, currency)
    RegistrationFeeInvoice.new(:status => AT_MEETING,
      :price => price, :currency => currency,
      :invoice_id => RegistrationFeeInvoice.generate_invoice_id)
  end

  # Create unique invoice ID
  def self.generate_invoice_id
    # To-do: improve invoice id, make alphanumeric
    (rand * 10000000000).truncate.to_s
  end
end
