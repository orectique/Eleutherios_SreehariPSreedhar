// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.0;

// We need some util functions for strings.
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";


import { Base64 } from "./libraries/Base64.sol";

contract EunomiaNFT is ERC721URIStorage {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  // This is our SVG code. All we need to change is the word that's displayed. Everything else stays the same.
  // So, we make a baseSvg variable here that all our NFTs can use.
  //string baseSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='black' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";
  string baseSvg = "<svg version='1.0' xmlns='http://www.w3.org/2000/svg' width='300.000000pt' height='300.000000pt' viewBox='0 0 300.000000 300.000000' preserveAspectRatio='xMidYMid meet'> <g transform='translate(0.000000,300.000000) scale(0.100000,-0.100000)' fill='#000000' stroke='none'> <path d='M0 1500 l0 -1500 1500 0 1500 0 0 1500 0 1500 -1500 0 -1500 0 0 -1500z m720 1167 c0 -12 3 -32 6 -44 6 -23 5 -23 -80 -23 l-87 0 3 38 3 37 60 5 c33 3 68 6 78 7 11 1 17 -5 17 -20z m185 1 c3 -13 4 -88 2 -168 l-2 -145 -80 0 -80 0 -3 113 c-3 109 -2 113 20 122 l23 9 -22 0 c-19 1 -23 7 -23 30 0 57 6 61 86 61 68 0 74 -2 79 -22z m-365 -27 l0 -38 -71 -7 c-39 -3 -75 -4 -80 -1 -13 9 -11 59 3 73 7 7 40 12 80 12 l68 0 0 -39z m-180 -11 l0 -40 -80 0 c-86 0 -89 2 -74 58 6 20 12 22 80 22 l74 0 0 -40z m180 -165 l0 -115 -53 0 c-48 0 -55 3 -65 25 -7 14 -19 28 -27 31 -12 5 -15 24 -15 84 0 90 -3 87 98 89 l62 1 0 -115z m188 3 l-3 -113 -82 -3 -83 -3 0 116 0 115 85 0 86 0 -3 -112z m-368 22 c0 -68 -3 -81 -19 -90 -11 -5 -23 -19 -26 -30 -5 -17 -15 -20 -61 -20 l-54 0 0 110 0 110 80 0 80 0 0 -80z m200 -280 c0 -55 -2 -100 -5 -100 -3 0 -10 10 -16 23 -27 59 -39 72 -81 82 -30 7 -42 15 -39 25 2 8 6 27 9 43 4 26 6 27 68 27 l64 0 0 -100z m180 -15 l0 -115 -51 0 c-53 0 -54 3 -20 45 15 19 15 19 -3 5 -18 -14 -19 -13 -13 8 3 13 3 30 0 38 -7 20 -28 -3 -49 -55 -9 -23 -19 -41 -23 -41 -3 0 -5 52 -3 115 l3 115 80 0 79 0 0 -115z m178 3 l-3 -113 -77 -3 -78 -3 0 116 0 115 80 0 81 0 -3 -112z m-598 87 c19 -23 5 -42 -50 -70 l-50 -25 0 55 0 55 44 0 c26 0 48 -6 56 -15z m365 -217 l55 4 0 -116 c0 -92 -3 -116 -14 -116 -8 0 -16 7 -20 15 -3 8 -12 15 -21 15 -8 0 -15 -7 -15 -15 0 -11 -12 -15 -45 -15 l-45 0 0 68 c0 60 2 68 23 77 18 8 22 17 21 55 0 25 1 40 3 34 2 -7 24 -9 58 -6z m235 -113 l0 -115 -56 0 c-46 0 -55 3 -50 15 3 9 0 15 -9 15 -8 0 -15 -7 -15 -15 0 -8 -7 -15 -15 -15 -12 0 -15 19 -15 115 l0 115 80 0 80 0 0 -115z m-372 56 c7 -9 12 -45 12 -93 l0 -78 -34 0 c-31 0 -34 3 -39 37 -4 20 -4 70 0 110 6 73 6 73 27 56 12 -10 27 -24 34 -32z'/></g> <style>.base { fill: white; font-family: serif; font-size: 24px; }</style><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";


  uint256 total_dump = 0;

  event NFTMinted(address sender, uint256 tokenId);

  constructor() ERC721 ("EunomiaNFT", "EUNOMIA") {
    console.log("Let's give out some tokens. Woah!");
  }


  function makeAnNFT(string memory text_input) public {
    uint256 newItemId = _tokenIds.current();

    string memory combinedWord = text_input;

    string memory finalSvg = string(abi.encodePacked(baseSvg, combinedWord, "</text></svg>"));

    

    
    // Get all the JSON metadata in place and base64 encode it.
    string memory json = Base64.encode(
        bytes(
            string(
                abi.encodePacked(
                    '{"name": "',
                    // We set the title of our NFT as the generated word.
                    combinedWord,
                    '", "description": "Tokens of appreciation from the city of Eleutherios.", "image": "data:image/svg+xml;base64,',
                    // We add data:image/svg+xml;base64 and then append our base64 encode our svg.
                    Base64.encode(bytes(finalSvg)),
                    '"}'
                )
            )
        )
    );

    // Just like before, we prepend data:application/json;base64, to our data.
    string memory finalTokenUri = string(
        abi.encodePacked("data:application/json;base64,", json)
    );

    console.log("\n--------------------");
    console.log(finalSvg);
    console.log("--------------------\n");

    _safeMint(msg.sender, newItemId);
  
    // We'll be setting the tokenURI later!
    _setTokenURI(newItemId, finalTokenUri);
  
    _tokenIds.increment();
    console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);

    total_dump += 1;

    emit NFTMinted(msg.sender, newItemId);
  }


    function get_dump() public view returns (uint256){
        return total_dump;
    }

}