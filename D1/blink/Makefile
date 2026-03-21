.PHONY: all flash clean

BUILD_DIR = build

all:
	cmake -B $(BUILD_DIR) -DCMAKE_BUILD_TYPE=Debug > /dev/null
	make -C $(BUILD_DIR) -j4

flash:
	cp $(BUILD_DIR)/blink_bare.uf2 /run/media/$(USER)/RPI-RP2/

clean:
	rm -rf $(BUILD_DIR)