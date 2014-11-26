
typedef Point = { x: Int, y: Int };

abstract Hex(Point) from Point to Point {
    inline public function new(point :Point) {
        this = point;
    }

    public var x(get, set) :Int;
    public var y(get, set) :Int;

    @:op(A + B)
    public function add(other :Point) {
        return { x: this.x + other.x, y: this.y + other.y };
    }

    @:op(A * B)
    public function scale(s :Int) {
        return { x: this.x * s, y: this.y * s };
    }

    function get_x() {
        return this.x;
    }

    function set_x(x :Int) {
        this.x = x;
        return x;
    }

    function get_y() {
        return this.y;
    }

    function set_y(y :Int) {
        this.y = y;
        return y;
    }

    public function clone() :Hex {
        return { x: x, y: y };
    }

    @:to
    public function toString() :String {
        return '${this.x},${this.y}';
    }
}

enum Direction {
    NW;
    NE;
    E;
    SE;
    SW;
    W;
}

// TODO: Inline functions?
// TODO: Make directions into enums
class HexMap<TValue> {
    var map :Map<String, { key: Hex, value: TValue }>;

    public function new() {
        map = new Map<String, { key: Hex, value: TValue }>();
    }

    public function setTile(key :Hex, value :TValue) :TValue {
        map.set(key, { key: key, value: value });
        // trace('setTile, key: $key, value: $value');
        return value;
    }

    public function getTile(key :Hex) :Null<TValue> {
        // trace('getTile, key: $key, exists: ${map.exists(key)}, value: ${map.get(key)}');
        var tile = map.get(key);
        if (tile == null) return null;
        return tile.value;
    }

    public function getTiles() :Array<TValue> {
        var hexes :Array<TValue> = [];
        for (hex in map.iterator()) {
            hexes.push(hex.value);
        }
        return hexes;
        // return map.iterator();
    }

    public function getKeys() :Array<Hex> {
        var hexes :Array<Hex> = [];
        for (hex in map.iterator()) {
            hexes.push(hex.key);
        }
        return hexes;
        // return map.keys();
    }

    public function getDirection(direction :Direction) :Hex {
        var neighbors = [
            { x:  1, y: 0}, { x:  1, y: -1}, { x: 0, y: -1 },
            { x: -1, y: 0}, { x: -1, y:  1}, { x: 0, y:  1 }
        ];
        var dir = switch (direction) {
            case E:  0;
            case NE: 1;
            case NW: 2;
            case W:  3;
            case SW: 4;
            case SE: 5;
        }
        return neighbors[dir];
    }

    public function getNeighbor(hex :Hex, direction :Direction) :Hex {
        return hex + getDirection(direction);
    }

    public function getNextNeighbor(hex :Hex, direction :Direction) :Hex {
        var neighbor = hex;
        do {
            neighbor = neighbor + getDirection(direction);
        } while (map.exists(neighbor) && getTile(neighbor) == null); // until !exists or has tile
        return neighbor;
    }

    public function getRing(hex :Hex, R :Int) :Array<Hex> {
        var H = hex + getDirection(Direction.SW) * R;
        var results = [];
        for (i in [E, NE, NW, W, SW, SE]) {
            for (j in 0 ... R) {
                results.push(H);
                H = getNeighbor(H, i);
            }
        }
        return results;
    }

    public function getRange(hex :Hex, rStart :Int, rEnd :Int) {
        // var results = [];
        // for (R in rStart ... rEnd) {
        //     results.push(getRing(hex, R));
        // }
        // return results;

        return [ for (R in rStart ... rEnd) getRing(hex, R) ];
    }

    // public function getReachableTiles(hex :Hex, movement :Int, passableFunc: Hex -> Bool) {
    //     var visited = new StringMap<Hex>();
    //     visited[hex] = hex;
    //     var fringes = [[hex]];
    //     for (var k = 0; k < movement; k++) {
    //         fringes[k + 1] = [];
    //         for (H in fringes[k]) {
    //             for (dir in 0 ... 6) {
    //                 var neighbor = H + getDirection(dir);
    //                 var neighborData = getTile(neighbor);
    //                 if (!neighborData) {
    //                     // Ensure that tiles outside the view are not considered again
    //                     visited[neighbor] = neighbor;
    //                 } else if (!visited[neighbor.id] && passableFunc(neighborData)) {
    //                     visited[neighbor] = neighbor;
    //                     fringes[k + 1].push(neighbor);
    //                 }
    //             }
    //         }
    //     }
    //     return _.values(visited);
    // }
}

// function HexMap(data) {
//   var me = this;
//   this.map = data || {};

//   this.set = function(key, data) {
//     this.map[key] = data;
//   };

//   this.get = function(key) {
//     return this.map[key];
//   };

//   this.getKeys = function() {
//     return _.keys(this.map);
//   };

//   this.getValues = function() {
//     return _.values(this.map);
//   };

//   this.getValuesWithKeys = function(keyName) {
//     keyName = keyName || 'key';
//     return _.map(this.map, function(value, key) {
//       return _.extend(value, {'key': key});
//     });
//   };

//   this.getDirection = function(direction) {
//     var neighbors = [
//         Hex(+1,  0), Hex(+1, -1), Hex( 0, -1),
//         Hex(-1,  0), Hex(-1, +1), Hex( 0, +1)
//     ];
//     return neighbors[direction];
//   };

//   this.getNeighbor = function(hex, direction) {
//     var directionHex = this.getDirection(direction);
//     return hex.add(directionHex);
//   };

//   this.getRing = function(hex, R) {
//     var H = hex.add(this.getDirection(4).scale(R));
//     var results = [];
//     for (var i = 0; i < 6; i++) {
//       for (var j = 0; j < R; j++) {
//         results.push(H);
//         H = this.getNeighbor(H, i);
//       }
//     }
//     return results;
//   };

//   this.getRange = function(hex, rStart, rEnd) {
//     var results = [];
//     for (var R = rStart; R <= rEnd; R++) {
//       results.push(this.getRing(hex, R));
//     }
//     return _.flatten(results);
//   };

//   this.getReachableTiles = function(hex, movement, passableFunc) {
//     var visited = {};
//     visited[hex.id] = hex;
//     var fringes = [[hex]];
//     for (var k = 0; k < movement; k++) {
//       fringes[k + 1] = [];
//       fringes[k].forEach(function(H) {
//         for (var dir = 0; dir < 6; dir++) {
//           var neighbor = H.add(me.getDirection(dir));
//           var neighborData = me.get(neighbor.id);
//           if (!neighborData) {
//             // Ensure that tiles outside the view are not considered again
//             visited[neighbor.id] = neighbor;
//           } else if (!visited[neighbor.id] && (passableFunc && passableFunc(neighborData))) {
//             visited[neighbor.id] = neighbor;
//             fringes[k + 1].push(neighbor);
//           }
//         }
//       });
//     }
//     return _.values(visited);
//   };

//   this.toString = function(tileRepresentationFunc) {
//     var coords = _.chain(this.getKeys())
//       .map(function(key) {
//         var parts = key.split(',');
//         return { x: parseInt(parts[0]), y: parseInt(parts[1]) };
//       })
//       .value();

//     var xs = _.pluck(coords, 'x');
//     var ys = _.pluck(coords, 'y');
//     var minX = _.min(xs);
//     var maxX = _.max(xs);
//     var minY = _.min(ys);
//     var maxY = _.max(ys);

//     var mapStr = '\n';
//     for (var y = minY - 1; y < minY; y++) {
//       for (var x = minX; x <= maxX; x++) {
//         mapStr += (x === minX || minY < 0 ? '  ' : '') + ' ' + (x < 0 ? x : ' ' + x);
//       }
//       mapStr += '\n';
//     }

//     for (var y = minY; y <= maxY; y++) {
//       mapStr += (y < 0 ? y : ' ' + y) + ' ';
//       for (var x = minX; x <= maxX; x++) {
//         var tile = this.get(x + ',' + y);
//         mapStr += (!tile ? '   ' : '[' + tileRepresentationFunc(tile) + ']');
//       }
//       mapStr += '\n';
//     }

//     return mapStr;
//   };
// }
