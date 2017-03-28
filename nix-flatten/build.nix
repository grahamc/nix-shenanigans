{ testfile ? ./test/attrset.nix }:
let
  pkgs = import <nixpkgs> {};
  lib = pkgs.lib;

  callOrRet = x:
    if (builtins.isFunction x)
    then x {}
    else x;

  loadInput = src: callOrRet (import src);

  flatten = val:
    map
      (elem:
        let
          attr = builtins.concatStringsSep "." elem.path;
        in elem // { attr = attr; }
      )
      (
        if lib.isList val then (flattenListToAttrList [] val)
        else if lib.isAttrs val then (flattenAttrsetToAttrList [] val)
        else throw "flatten can't handle this? ${val}"
      );

  flatten' = path: val:
    (
      if lib.isDerivation val then (pathValueElem path val)
      else if lib.isBool val then (pathValueElem path val)
      else if lib.isInt val then (pathValueElem path val)
      else if lib.isString val then (pathValueElem path val)
      else if lib.isFunction val then (flatten' path (val {}))
      else if lib.isList val then (flattenListToAttrList path val)
      else if lib.isAttrs val then (flattenAttrsetToAttrList path val)
      else throw "flatten' can't handle this? ${val}"
    );

  pathValueElem = path: value: [{
    path = path;
    value = value;
  }];

  flattenAttrsetToAttrList = path: attrset:
    let
      keys = builtins.attrNames attrset;
    in builtins.concatLists (
        map (key: (
          let
            ident = path ++ [key];
            curValue = (builtins.getAttr key attrset);
          in flatten' ident curValue
        )) keys
      )
    ;

  flattenListToAttrList = path: xs:
    builtins.concatLists
      (lib.imap
        (i: v:
          let
            ident = path ++ ["${toString (i - 1)}"];
          in
            flatten' ident v
        )
        xs);

in { flat = (flatten (loadInput testfile)); }
