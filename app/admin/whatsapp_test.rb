ActiveAdmin.register_page "WhatsApp Test" do
  menu label: "WhatsApp Test", priority: 20

  controller do
    layout 'admin'

    def send_test
      message_type = params[:message_type]
      phone_number = params[:phone_number]

      if phone_number.blank?
        render json: { success: false, error: "Phone number is required" }, status: 400
        return
      end

      begin
        result = case message_type
        when "bid_template"
          WhatsappService.send_bid_template_message(
            to: phone_number,
            product_name: "iPhone 14 Pro 256GB",
            amount: 1500,
            quantity: 2,
            time: Time.current.strftime("%H:%M")
          )
        when "counter_bid_template"
          WhatsappService.send_bid_template_message(
            to: phone_number,
            product_name: "iPhone 14 Pro 256GB",
            amount: 1350,
            quantity: 2,
            time: Time.current.strftime("%H:%M")
          )
        when "order_template"
          WhatsappService.send_order_template_message(
            to: phone_number,
            order_amount: 3500,
            total_items: 5,
            time: Time.current.strftime("%H:%M")
          )
        when "generic_template"
          WhatsappService.send_templated_message(
            to: phone_number,
            params: {
              "1": "Samsung Galaxy S21",
              "2": "500",
              "3": "1",
              "4": "2 days"
            }
          )
        when "order_processed"
          WhatsappService.send_order_notification(
            order_id: 12345,
            phone_number: phone_number,
            customer_name: "John Doe"
          )
        when "order_shipped"
          WhatsappService.send_order_shipped_notification(
            order_id: 12345,
            phone_number: phone_number,
            tracking_number: "TRK-2025-ABC123"
          )
        when "bid_alert"
          WhatsappService.send_bid_notification(
            bid_amount: 1200,
            product_name: "iPhone 14 Pro 256GB",
            phone_number: phone_number,
            buyer_name: "Jane Smith"
          )
        when "welcome"
          WhatsappService.send_welcome_message(
            phone_number: phone_number,
            user_name: "John Doe"
          )
        else
          raise ArgumentError, "Unknown message type: #{message_type}"
        end

        render json: {
          success: true,
          message: "#{message_type.titleize} sent successfully!",
          message_sid: result.sid
        }, status: 200

      rescue WhatsappService::ConfigurationError => e
        render json: { success: false, error: "Configuration Error: #{e.message}" }, status: 500
      rescue WhatsappService::TwilioError => e
        render json: { success: false, error: "Twilio Error: #{e.message}", code: e.code }, status: 400
      rescue => e
        render json: { success: false, error: e.message }, status: 500
      end
    end
  end

  page_action :send_test, method: :post

  content title: "WhatsApp Message Testing" do
    config_status = WhatsappService.configuration_status

    # Configuration status panel
    div class: "bg-color" do
      div class: "row mb-4" do
        div class: "col-12" do
          raw_html = <<~HTML
            <div class="card shadow borderNone">
              <div class="card-body setPaddingCard">
                <h5 class="mb-3" style="font-weight: 600; color: #333;">Configuration Status</h5>
                <div class="d-flex flex-wrap" style="gap: 12px;">
                  <span class="badge #{config_status[:account_sid] ? 'bg-success' : 'bg-danger'}" style="padding: 8px 14px; font-size: 13px; border-radius: 20px;">
                    Account SID: #{config_status[:account_sid] ? 'Set' : 'Missing'}
                  </span>
                  <span class="badge #{config_status[:auth_token] ? 'bg-success' : 'bg-danger'}" style="padding: 8px 14px; font-size: 13px; border-radius: 20px;">
                    Auth Token: #{config_status[:auth_token] ? 'Set' : 'Missing'}
                  </span>
                  <span class="badge #{config_status[:whatsapp_number] ? 'bg-success' : 'bg-danger'}" style="padding: 8px 14px; font-size: 13px; border-radius: 20px;">
                    WhatsApp Number: #{config_status[:whatsapp_number] ? 'Set' : 'Missing'}
                  </span>
                  <span class="badge #{config_status[:messaging_service_sid] ? 'bg-success' : 'bg-danger'}" style="padding: 8px 14px; font-size: 13px; border-radius: 20px;">
                    Messaging Service: #{config_status[:messaging_service_sid] ? 'Set' : 'Missing'}
                  </span>
                  <span class="badge #{config_status[:bid_template_sid] ? 'bg-success' : 'bg-danger'}" style="padding: 8px 14px; font-size: 13px; border-radius: 20px;">
                    Bid Template: #{config_status[:bid_template_sid] ? 'Set' : 'Missing'}
                  </span>
                  <span class="badge #{config_status[:order_template_sid] ? 'bg-success' : 'bg-danger'}" style="padding: 8px 14px; font-size: 13px; border-radius: 20px;">
                    Order Template: #{config_status[:order_template_sid] ? 'Set' : 'Missing'}
                  </span>
                  <span class="badge #{config_status[:message_template_sid] ? 'bg-success' : 'bg-danger'}" style="padding: 8px 14px; font-size: 13px; border-radius: 20px;">
                    Generic Template: #{config_status[:message_template_sid] ? 'Set' : 'Missing'}
                  </span>
                </div>
              </div>
            </div>
          HTML
          raw(raw_html)
        end
      end

      # Message test cards
      div class: "row" do
        # ---- Automated Notifications Section ----
        div class: "col-12 mb-3" do
          raw('<h5 style="font-weight: 600; color: #333;">Automated Notifications (sent via model callbacks)</h5>')
          raw('<hr style="margin-top: 4px;">')
        end

        # 1. New Bid Template
        div class: "col-xl-4 col-md-6 mb-3" do
          raw(<<~HTML)
            <div class="card shadow borderNone h-100">
              <div class="card-body setPaddingCard d-flex flex-column">
                <div class="d-flex align-items-center mb-2">
                  <span style="font-size: 24px; margin-right: 10px;">💰</span>
                  <h6 class="mb-0" style="font-weight: 600;">New Bid (Template)</h6>
                </div>
                <p class="text-muted" style="font-size: 13px; flex-grow: 1;">
                  Sent to <strong>seller</strong> when a buyer places a bid on their product.<br>
                  <em>Triggered by: Bid.after_create_commit</em><br><br>
                  <strong>Mock data:</strong> iPhone 14 Pro 256GB, Amount: 1500, Qty: 2
                </p>
                <button class="btn btn-success btn-block wa-test-btn" data-type="bid_template" style="border-radius: 8px;">
                  Send Test Message
                </button>
              </div>
            </div>
          HTML
        end

        # 2. Counter Bid to Buyer (Template)
        div class: "col-xl-4 col-md-6 mb-3" do
          raw(<<~HTML)
            <div class="card shadow borderNone h-100">
              <div class="card-body setPaddingCard d-flex flex-column">
                <div class="d-flex align-items-center mb-2">
                  <span style="font-size: 24px; margin-right: 10px;">🔄</span>
                  <h6 class="mb-0" style="font-weight: 600;">Counter Bid to Buyer (Template)</h6>
                </div>
                <p class="text-muted" style="font-size: 13px; flex-grow: 1;">
                  Sent to <strong>buyer</strong> when a seller makes a counter offer on their bid.<br>
                  <em>Triggered by: sellers#update_bid (negotiate)</em><br><br>
                  <strong>Mock data:</strong> iPhone 14 Pro 256GB, Amount: 1350, Qty: 2
                </p>
                <button class="btn btn-success btn-block wa-test-btn" data-type="counter_bid_template" style="border-radius: 8px;">
                  Send Test Message
                </button>
              </div>
            </div>
          HTML
        end

        # 3. New Order Template
        div class: "col-xl-4 col-md-6 mb-3" do
          raw(<<~HTML)
            <div class="card shadow borderNone h-100">
              <div class="card-body setPaddingCard d-flex flex-column">
                <div class="d-flex align-items-center mb-2">
                  <span style="font-size: 24px; margin-right: 10px;">📦</span>
                  <h6 class="mb-0" style="font-weight: 600;">New Order (Template)</h6>
                </div>
                <p class="text-muted" style="font-size: 13px; flex-grow: 1;">
                  Sent to <strong>seller</strong> when an order is placed on their inventory.<br>
                  <em>Triggered by: Order.after_create_commit</em><br><br>
                  <strong>Mock data:</strong> Amount: $3,500, Items: 5
                </p>
                <button class="btn btn-success btn-block wa-test-btn" data-type="order_template" style="border-radius: 8px;">
                  Send Test Message
                </button>
              </div>
            </div>
          HTML
        end

        # 3. Generic Template
        div class: "col-xl-4 col-md-6 mb-3" do
          raw(<<~HTML)
            <div class="card shadow borderNone h-100">
              <div class="card-body setPaddingCard d-flex flex-column">
                <div class="d-flex align-items-center mb-2">
                  <span style="font-size: 24px; margin-right: 10px;">📋</span>
                  <h6 class="mb-0" style="font-weight: 600;">Generic Template</h6>
                </div>
                <p class="text-muted" style="font-size: 13px; flex-grow: 1;">
                  Generic Twilio template message with product, amount, quantity and time parameters.<br><br>
                  <strong>Mock data:</strong> Samsung Galaxy S21, Amount: 500, Qty: 1, Time: 2 days
                </p>
                <button class="btn btn-success btn-block wa-test-btn" data-type="generic_template" style="border-radius: 8px;">
                  Send Test Message
                </button>
              </div>
            </div>
          HTML
        end

        # ---- Text Message Notifications Section ----
        div class: "col-12 mb-3 mt-2" do
          raw('<h5 style="font-weight: 600; color: #333;">Text Message Notifications (fallback / manual)</h5>')
          raw('<hr style="margin-top: 4px;">')
        end

        # 4. Order Processed
        div class: "col-xl-4 col-md-6 mb-3" do
          raw(<<~HTML)
            <div class="card shadow borderNone h-100">
              <div class="card-body setPaddingCard d-flex flex-column">
                <div class="d-flex align-items-center mb-2">
                  <span style="font-size: 24px; margin-right: 10px;">✅</span>
                  <h6 class="mb-0" style="font-weight: 600;">Order Processed</h6>
                </div>
                <p class="text-muted" style="font-size: 13px; flex-grow: 1;">
                  Text notification confirming an order has been processed successfully.<br><br>
                  <strong>Mock data:</strong> Order #12345, Customer: John Doe
                </p>
                <button class="btn btn-primary btn-block wa-test-btn" data-type="order_processed" style="border-radius: 8px;">
                  Send Test Message
                </button>
              </div>
            </div>
          HTML
        end

        # 5. Order Shipped
        div class: "col-xl-4 col-md-6 mb-3" do
          raw(<<~HTML)
            <div class="card shadow borderNone h-100">
              <div class="card-body setPaddingCard d-flex flex-column">
                <div class="d-flex align-items-center mb-2">
                  <span style="font-size: 24px; margin-right: 10px;">🚚</span>
                  <h6 class="mb-0" style="font-weight: 600;">Order Shipped</h6>
                </div>
                <p class="text-muted" style="font-size: 13px; flex-grow: 1;">
                  Text notification that an order has been shipped with tracking info.<br><br>
                  <strong>Mock data:</strong> Order #12345, Tracking: TRK-2025-ABC123
                </p>
                <button class="btn btn-primary btn-block wa-test-btn" data-type="order_shipped" style="border-radius: 8px;">
                  Send Test Message
                </button>
              </div>
            </div>
          HTML
        end

        # 6. Bid Alert
        div class: "col-xl-4 col-md-6 mb-3" do
          raw(<<~HTML)
            <div class="card shadow borderNone h-100">
              <div class="card-body setPaddingCard d-flex flex-column">
                <div class="d-flex align-items-center mb-2">
                  <span style="font-size: 24px; margin-right: 10px;">🔔</span>
                  <h6 class="mb-0" style="font-weight: 600;">Bid Alert</h6>
                </div>
                <p class="text-muted" style="font-size: 13px; flex-grow: 1;">
                  Text notification alerting about a new bid on a product.<br><br>
                  <strong>Mock data:</strong> $1,200 bid on iPhone 14 Pro 256GB by Jane Smith
                </p>
                <button class="btn btn-primary btn-block wa-test-btn" data-type="bid_alert" style="border-radius: 8px;">
                  Send Test Message
                </button>
              </div>
            </div>
          HTML
        end

        # 7. Welcome Message
        div class: "col-xl-4 col-md-6 mb-3" do
          raw(<<~HTML)
            <div class="card shadow borderNone h-100">
              <div class="card-body setPaddingCard d-flex flex-column">
                <div class="d-flex align-items-center mb-2">
                  <span style="font-size: 24px; margin-right: 10px;">🎉</span>
                  <h6 class="mb-0" style="font-weight: 600;">Welcome Message</h6>
                </div>
                <p class="text-muted" style="font-size: 13px; flex-grow: 1;">
                  Welcome text sent to a new user upon registration.<br><br>
                  <strong>Mock data:</strong> User: John Doe
                </p>
                <button class="btn btn-primary btn-block wa-test-btn" data-type="welcome" style="border-radius: 8px;">
                  Send Test Message
                </button>
              </div>
            </div>
          HTML
        end
      end

      # Result display area
      div class: "row mt-3" do
        div class: "col-12" do
          raw(<<~HTML)
            <div id="wa-test-result" class="card shadow borderNone" style="display: none;">
              <div class="card-body setPaddingCard">
                <h6 id="wa-result-title" style="font-weight: 600;"></h6>
                <pre id="wa-result-body" style="background: #f8f9fa; padding: 15px; border-radius: 8px; white-space: pre-wrap; font-size: 13px;"></pre>
              </div>
            </div>
          HTML
        end
      end
    end

    # Phone number modal (pure CSS/HTML, no Bootstrap JS needed)
    raw(<<~HTML)
      <style>
        .wa-modal-overlay {
          display: none;
          position: fixed;
          top: 0; left: 0; right: 0; bottom: 0;
          background: rgba(0,0,0,0.5);
          z-index: 9999;
          justify-content: center;
          align-items: center;
        }
        .wa-modal-overlay.active {
          display: flex;
        }
        .wa-modal-box {
          background: #fff;
          border-radius: 12px;
          width: 420px;
          max-width: 90vw;
          box-shadow: 0 10px 40px rgba(0,0,0,0.2);
          overflow: hidden;
        }
        .wa-modal-header {
          padding: 20px 24px;
          border-bottom: 1px solid #eee;
          display: flex;
          justify-content: space-between;
          align-items: center;
        }
        .wa-modal-header h5 { margin: 0; font-weight: 600; font-size: 18px; }
        .wa-modal-close {
          background: none; border: none; font-size: 24px; cursor: pointer;
          color: #666; line-height: 1;
        }
        .wa-modal-close:hover { color: #000; }
        .wa-modal-body { padding: 24px; }
        .wa-modal-body label { font-weight: 500; display: block; margin-bottom: 6px; }
        .wa-modal-body input[type="text"] {
          width: 100%; padding: 10px 14px; font-size: 15px;
          border: 1px solid #ced4da; border-radius: 8px; box-sizing: border-box;
        }
        .wa-modal-body input[type="text"]:focus {
          outline: none; border-color: #28a745; box-shadow: 0 0 0 2px rgba(40,167,69,0.2);
        }
        .wa-modal-footer {
          padding: 16px 24px;
          border-top: 1px solid #eee;
          display: flex;
          justify-content: flex-end;
          gap: 10px;
        }
        .wa-modal-footer button { border-radius: 8px; padding: 8px 20px; cursor: pointer; font-size: 14px; }
        .wa-btn-cancel { background: #6c757d; color: #fff; border: none; }
        .wa-btn-cancel:hover { background: #5a6268; }
        .wa-btn-send { background: #28a745; color: #fff; border: none; }
        .wa-btn-send:hover { background: #218838; }
        .wa-btn-send:disabled { background: #94d3a2; cursor: not-allowed; }
        .wa-spinner { display: inline-block; width: 14px; height: 14px; border: 2px solid #fff;
          border-top-color: transparent; border-radius: 50%; animation: wa-spin 0.6s linear infinite; }
        @keyframes wa-spin { to { transform: rotate(360deg); } }
      </style>

      <div class="wa-modal-overlay" id="waPhoneModal">
        <div class="wa-modal-box">
          <div class="wa-modal-header">
            <h5>Enter Phone Number</h5>
            <button type="button" class="wa-modal-close" id="waModalClose">&times;</button>
          </div>
          <div class="wa-modal-body">
            <p style="color: #6c757d; font-size: 13px; margin-bottom: 16px;">
              Enter the WhatsApp number to send the test message to. Use international format (e.g. +254712345678).
            </p>
            <label for="waTestPhone">Phone Number</label>
            <input type="text" id="waTestPhone" placeholder="+254712345678">
            <input type="hidden" id="waTestType" value="">
          </div>
          <div class="wa-modal-footer">
            <button type="button" class="wa-btn-cancel" id="waModalCancel">Cancel</button>
            <button type="button" class="wa-btn-send" id="waConfirmSend">
              <span id="waSendText">Send Message</span>
              <span id="waSendSpinner" style="display: none;">
                <span class="wa-spinner"></span> Sending...
              </span>
            </button>
          </div>
        </div>
      </div>

      <script>
        document.addEventListener('DOMContentLoaded', function() {
          var modal = document.getElementById('waPhoneModal');
          var phoneInput = document.getElementById('waTestPhone');
          var typeInput = document.getElementById('waTestType');
          var sendBtn = document.getElementById('waConfirmSend');
          var sendText = document.getElementById('waSendText');
          var sendSpinner = document.getElementById('waSendSpinner');
          var resultBox = document.getElementById('wa-test-result');
          var resultTitle = document.getElementById('wa-result-title');
          var resultBody = document.getElementById('wa-result-body');

          function openModal(messageType) {
            typeInput.value = messageType;
            phoneInput.value = '';
            modal.classList.add('active');
            setTimeout(function() { phoneInput.focus(); }, 100);
          }

          function closeModal() {
            modal.classList.remove('active');
          }

          // Open modal on button click
          document.querySelectorAll('.wa-test-btn').forEach(function(btn) {
            btn.addEventListener('click', function() {
              openModal(this.getAttribute('data-type'));
            });
          });

          // Close modal
          document.getElementById('waModalClose').addEventListener('click', closeModal);
          document.getElementById('waModalCancel').addEventListener('click', closeModal);
          modal.addEventListener('click', function(e) {
            if (e.target === modal) closeModal();
          });

          // Enter key submits
          phoneInput.addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
              e.preventDefault();
              sendBtn.click();
            }
          });

          // Send test message
          sendBtn.addEventListener('click', function() {
            var phone = phoneInput.value.trim();
            var type = typeInput.value;

            if (!phone) {
              alert('Please enter a phone number');
              return;
            }

            // Show spinner
            sendText.style.display = 'none';
            sendSpinner.style.display = 'inline';
            sendBtn.disabled = true;

            var csrfToken = document.querySelector('meta[name="csrf-token"]');
            var token = csrfToken ? csrfToken.getAttribute('content') : '';

            var formData = new FormData();
            formData.append('phone_number', phone);
            formData.append('message_type', type);
            formData.append('authenticity_token', token);

            fetch('/admin/whatsapp_test/send_test', {
              method: 'POST',
              body: formData
            })
            .then(function(response) {
              return response.json().then(function(data) {
                return { ok: response.ok, data: data };
              });
            })
            .then(function(result) {
              closeModal();
              if (result.ok) {
                showResult('success', result.data.message, JSON.stringify(result.data, null, 2));
              } else {
                showResult('error', 'Failed to send message', JSON.stringify(result.data, null, 2));
              }
            })
            .catch(function(err) {
              closeModal();
              showResult('error', 'Network error', err.message);
            })
            .finally(function() {
              sendText.style.display = 'inline';
              sendSpinner.style.display = 'none';
              sendBtn.disabled = false;
            });
          });

          function showResult(type, title, body) {
            resultTitle.textContent = title;
            resultBody.textContent = body;

            if (type === 'success') {
              resultTitle.style.color = '#28a745';
              resultBox.style.borderLeft = '4px solid #28a745';
            } else {
              resultTitle.style.color = '#dc3545';
              resultBox.style.borderLeft = '4px solid #dc3545';
            }

            resultBox.style.display = 'block';

            setTimeout(function() {
              resultBox.style.display = 'none';
            }, 15000);
          }
        });
      </script>
    HTML
  end
end
