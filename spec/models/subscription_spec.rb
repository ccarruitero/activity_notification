describe ActivityNotification::Subscription, type: :model do

  it_behaves_like :subscription_api

  describe "with association" do
    it "belongs to target" do
      target = create(:confirmed_user)
      subscription = create(:subscription, target: target)
      expect(subscription.reload.target).to eq(target)
    end
  end

  describe "with validation" do
    before { @subscription = build(:subscription) }

    it "is valid with target and key" do
      expect(@subscription).to be_valid
    end

    it "is invalid with blank target" do
      @subscription.target = nil
      expect(@subscription).to be_invalid
      expect(@subscription.errors[:target].size).to eq(1)
    end

    it "is invalid with blank key" do
      @subscription.key = nil
      expect(@subscription).to be_invalid
      expect(@subscription.errors[:key].size).to eq(1)
    end

    #TODO
    # it "is invalid with non boolean value of subscribing" do
      # @subscription.subscribing = 'hoge'
      # expect(@subscription).to be_invalid
      # expect(@subscription.errors[:subscribing].size).to eq(1)
    # end
# 
    # it "is invalid with non boolean value of subscribing_to_email" do
      # @subscription.subscribing_to_email = 'hoge'
      # expect(@subscription).to be_invalid
      # expect(@subscription.errors[:subscribing_to_email].size).to eq(1)
    # end

    it "is invalid with true as subscribing_to_email and false as subscribing" do
      @subscription.subscribing = false
      @subscription.subscribing_to_email = true
      expect(@subscription).to be_invalid
      expect(@subscription.errors[:subscribing_to_email].size).to eq(1)
    end
  end

  describe "with scope" do
    context "to filter by association" do
      before do
        ActivityNotification::Subscription.delete_all
        @target_1, @key_1 = create(:confirmed_user), "key.1"
        @target_2, @key_2 = create(:confirmed_user), "key.2"
        @subscription_1 = create(:subscription, target: @target_1, key: @key_1)
        @subscription_2 = create(:subscription, target: @target_2, key: @key_2)
      end

      it "works with filtered_by_target scope" do
        subscriptions = ActivityNotification::Subscription.filtered_by_target(@target_1)
        expect(subscriptions.size).to eq(1)
        expect(subscriptions.first).to eq(@subscription_1)
        subscriptions = ActivityNotification::Subscription.filtered_by_target(@target_2)
        expect(subscriptions.size).to eq(1)
        expect(subscriptions.first).to eq(@subscription_2)
      end

      it "works with filtered_by_key scope" do
        subscriptions = ActivityNotification::Subscription.filtered_by_key(@key_1)
        expect(subscriptions.size).to eq(1)
        expect(subscriptions.first).to eq(@subscription_1)
        subscriptions = ActivityNotification::Subscription.filtered_by_key(@key_2)
        expect(subscriptions.size).to eq(1)
        expect(subscriptions.first).to eq(@subscription_2)
      end

      describe 'filtered_by_options scope' do
        context 'with filtered_by_key options' do
          it "works with filtered_by_options scope" do
            subscriptions = ActivityNotification::Subscription.filtered_by_options({ filtered_by_key: @key_1 })
            expect(subscriptions.size).to eq(1)
            expect(subscriptions.first).to eq(@subscription_1)
            subscriptions = ActivityNotification::Subscription.filtered_by_options({ filtered_by_key: @key_2 })
            expect(subscriptions.size).to eq(1)
            expect(subscriptions.first).to eq(@subscription_2)
          end
        end

        context 'with custom_filter options' do
          it "works with filtered_by_options scope" do
            if ActivityNotification.config.orm == :active_record
              subscriptions = ActivityNotification::Subscription.filtered_by_options({ custom_filter: ["key = ?", @key_1] })
              expect(subscriptions.size).to eq(1)
              expect(subscriptions.first).to eq(@subscription_1)
            end

            subscriptions = ActivityNotification::Subscription.filtered_by_options({ custom_filter: { key: @key_2 } })
            expect(subscriptions.size).to eq(1)
            expect(subscriptions.first).to eq(@subscription_2)
          end
        end
  
        context 'with no options' do
          it "works with filtered_by_options scope" do
            subscriptions = ActivityNotification::Subscription.filtered_by_options
            expect(subscriptions.size).to eq(2)
          end
        end
      end
    end

    context "to make order by created_at" do
      before do
        ActivityNotification::Subscription.delete_all
        @subscription_1 = create(:subscription, key: 'key.1')
        @subscription_2 = create(:subscription, key: 'key.2')
        @subscription_3 = create(:subscription, key: 'key.3')
        @subscription_4 = create(:subscription, key: 'key.4')
      end

      it "works with latest_order scope" do
        subscriptions = ActivityNotification::Subscription.latest_order
        expect(subscriptions.size).to eq(4)
        expect(subscriptions.first).to eq(@subscription_4)
        expect(subscriptions.last).to eq(@subscription_1)
      end

      it "works with earliest_order scope" do
        subscriptions = ActivityNotification::Subscription.earliest_order
        expect(subscriptions.size).to eq(4)
        expect(subscriptions.first).to eq(@subscription_1)
        expect(subscriptions.last).to eq(@subscription_4)
      end

      it "works with latest_subscribed_order scope" do
        @subscription_2.subscribe
        subscriptions = ActivityNotification::Subscription.latest_subscribed_order
        expect(subscriptions.size).to eq(4)
        expect(subscriptions.first).to eq(@subscription_2)
      end

      it "works with earliest_subscribed_order scope" do
        @subscription_3.subscribe
        subscriptions = ActivityNotification::Subscription.earliest_subscribed_order
        expect(subscriptions.size).to eq(4)
        expect(subscriptions.last).to eq(@subscription_3)
      end

      it "works with key_order scope" do
        subscriptions = ActivityNotification::Subscription.key_order
        expect(subscriptions.size).to eq(4)
        expect(subscriptions.first).to eq(@subscription_1)
        expect(subscriptions.last).to eq(@subscription_4)
      end
    end
  end
end