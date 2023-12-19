Ransack.configure do |config|
  config.custom_arrows = {
    up_arrow: "<span class='fr-icon-arrow-up-s-line fr-icon-sm' aria-hidden='true'></span>",
    down_arrow: "<span class='fr-icon-arrow-down-s-line fr-icon-sm' aria-hidden='true'></span>",
    default_arrow: "<img src='#{ActionController::Base.helpers.asset_path("expand-up-down-line.svg")}' class='table-header__arrows--expand' alt='expand'>"
  }
end
