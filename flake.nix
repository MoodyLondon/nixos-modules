{
  description = "Reusable NixOS modules";

  outputs = _: {
    nixosModules.aic8800d80 = ./modules/aic8800d80;
  };
}
