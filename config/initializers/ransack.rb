Ransack.configure do |config|
  assets_base_path = Rails.env.production? ? "/assets" : "assets"

  config.custom_arrows = {
    up_arrow: "<span class='fr-icon-arrow-up-s-line fr-icon-sm' aria-hidden='true'></span>",
    down_arrow: "<span class='fr-icon-arrow-down-s-line fr-icon-sm' aria-hidden='true'></span>",
    default_arrow: "<img src='#{assets_base_path}/expand-up-down-line.svg' class='table-header__arrows--expand' alt='expand'>"
  }
end
