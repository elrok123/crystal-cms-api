Kemalyst::Handler::Session.config do |config|
  # The secret is used to avoid the session data being changed.  The session
  # data is stored in a cookie.  To avoid changes being made, a security token
  # is generated using this secret.  To generate a secret, you can use the
  # following command:
  # crystal eval "require \"secure_random\"; puts SecureRandom.hex(64)"
  #
  config.secret = "ebeb2c621c78dd11adddec20dd96b8729b2ee3ca1bbdf3c080078f4941999269b240d2f5409564d1cb5f46f664014bc15262e3ff8b988f9ea995d3c3e0b91632"
end
