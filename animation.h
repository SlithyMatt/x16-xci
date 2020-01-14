#ifndef ANIMATION_H
#define ANIMATION_H

#include "config.h"
#include <stdint.h>

int parse_animation_node(const xci_config_node *node, uint8_t *bin);

#endif // ANIMATION_H
