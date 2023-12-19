Ransack.configure do |config|
  asset_filename = Rails.application.assets_manifest.assets['expand-up-down-line.svg'] || 'expand-up-down-line.svg'
  base_path = Rails.env.production? ? "" : "/assets"


  config.custom_arrows = {
    up_arrow: "<span class='fr-icon-arrow-up-s-line fr-icon-sm' aria-hidden='true'></span>",
    down_arrow: "<span class='fr-icon-arrow-down-s-line fr-icon-sm' aria-hidden='true'></span>",
    default_arrow: "<img src='#{base_path}/#{asset_filename}' class='table-header__arrows--expand' alt='expand'>"
  }
end
