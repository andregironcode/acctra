module BuyersHelper
    def icon_name(name)
        # Define a mapping of keywords to icons
        icon_mapping = {
          'mobile' => 'fa-mobile-screen',
          'mobiles' => 'fa-mobile-screen',
          'phones' => 'fa-mobile-screen',
          'laptop' => 'fa-laptop',
          'macbook' => 'fa-laptop',
          'headphone' => 'fa-headphone',
          'airpods' => 'fa-headphone',
          'handsfree' => 'fa-headphone'
        }
        icon = icon_mapping[name.downcase]
      
        unless icon
          icon || 'fa-question-circle' # Default icon if no match found
        end
        return icon
    end
end
