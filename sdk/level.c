#include "level.h"
#include "key.h"
#include "animation.h"
#include "menu.h"
#include "inventory.h"
#include "bitmap.h"
#include "vgm2x16opm.h"
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#define MAX_LEVEL_SIZE 8192
#define MAX_STATE_LABEL 63
#define MAX_TRIGGERS 64

typedef struct state_list_node {
   char label[MAX_STATE_LABEL+1];
   struct state_list_node *next;
} state_list_node_t;

state_list_node_t *state_list = NULL;
state_list_node_t *last_state = NULL;

char *sound_ids[127];
char *sound_fns[127];
int num_sounds = 0;

int state_index(const char* label) {
   char label_lc[MAX_STATE_LABEL+1];
   state_list_node_t *node = state_list;
   int i = 0;

   strn_tolower(label_lc,MAX_STATE_LABEL+1,label);
   while (node != NULL) {
      if (strcmp(label_lc,node->label) == 0) {
         return i;
      }
      node = node->next;
      i++;
   }

   return -1;
}

int sfx_index(const char *id) {
   int index = 0;
   int found = 0;

   while (!found && index < num_sounds) {
      if (strcmp(sound_ids[index],id) == 0) {
         found = 1;
      } else {
         index++;
      }
   }

   if (!found) {
      index = -1;
   }

   return index;
}

int parse_level_config(int zone, int level, const char *cfg_fn) {
   uint8_t *bin = calloc(MAX_LEVEL_SIZE,1);
   uint8_t *pal = &bin[2];
   xci_config_t cfg;
   xci_config_node_t *node;
   xci_val_list_t *val;
   int size = 34; // address header and 16-color palette for the level
   text_line_t *text_bin;
   go_level_t *go_level_bin;
   tool_trigger_t *tool_trigger_bin;
   item_trigger_t *item_trigger_bin;
   get_item_t *get_item_bin;
   int num;
   int num_triggers = 0;
   state_list_node_t *new_state = NULL;
   int bank;
   char bin_fn[15];
   FILE *ifp;
   FILE *ofp;
   int bitmap_defined = 0;
   int music_defined = 0;
   char *vgm_fn;
   uint8_t *music_sfx_buffer;
   int msb_header_size;
   int msb_size = 0;
   int sound_idx;
   uint8_t sample;

   num_sounds = 0;

   if (parse_config(cfg_fn, &cfg) < 0) {
      printf("parse_level_config: error parsing config source (%s)\n", cfg_fn);
      return -1;
   }

   // Header with load address
   bin[0] = 0x00;
   bin[1] = 0xC0;

   node = cfg.nodes;
   while (node != NULL) {
      switch (node->key) {
         case BITMAP:
            if (node->num_values < 1) {
               printf("parse_level_config: no filename specified for bitmap\n");
               return -1;
            }
            bank = level * 6 + 2;
            sprintf(bin_fn,"%03dL%d.%02d.BIN", zone, level, bank);
            if (conv_bitmap(node->values->val, bin_fn, pal) < 0) {
               printf("parse_level_config: error converting bitmap\n");
               return -1;
            }
            bitmap_defined = 1;
            break;
         case MUSIC:
            if (node->num_values < 1) {
               printf("parse_level_config: no filename specified for music\n");
               return -1;
            }
            vgm_fn = node->values->val;
            music_defined = 1;
            break;
         case SOUND:
            if (node->num_values < 2) {
               printf("parse_level_config: sound requires at least 2 values\n");
               return -1;
            }
            val = node->values;
            sound_ids[num_sounds] = val->val;
            val = val->next;
            sound_fns[num_sounds] = val->val;
            num_sounds++;
            break;
         case INIT_LEVEL:
         case FIRST_VISIT:
         case END_ANIM:
         case LINE_SKIP:
         case CLEAR_TEXT:
         case END_IF:
         case GIF_START:
         case GIF_PAUSE:
         case GIF_FRAME:
            bin[size++] = node->key;
            break;
         case TEXT_LINE:
            if (node->num_values < 2) {
               printf("parse_level_config: text requires at least 2 values\n");
               return -1;
            }
            text_bin = (text_line_t *)&bin[size];
            text_bin->key = TEXT_LINE;
            val = node->values;
            text_bin->style = atoi(val->val);
            val = val->next;
            if (concat_string_val(val,text_bin->text,MAX_TEXT_LINE) < 0) {
               printf("parse_level_config: error parsing text\n");
               return -1;
            }
            size += sizeof(text_line_t);
            break;
         case SCROLL:
            if (node->num_values < 1) {
               printf("parse_level_config: no value specified for scroll\n");
               return -1;
            }
            bin[size++] = SCROLL;
            bin[size++] = atoi(node->values->val);
            break;
         case GO_LEVEL:
            if (node->num_values < 2) {
               printf("parse_level_config: go_level requires 2 values\n");
               return -1;
            }
            go_level_bin = (go_level_t *)&bin[size];
            go_level_bin->key = GO_LEVEL;
            val = node->values;
            go_level_bin->zone = atoi(val->val);
            val = val->next;
            go_level_bin->level = atoi(val->val);
            size += sizeof(go_level_t);
            break;
         case TOOL_TRIGGER:
            num_triggers++;
            if (num_triggers > MAX_TRIGGERS) {
               printf("parse_level_config: too many triggers (max: %d)\n",
                      MAX_TRIGGERS);
               return -1;
            }
            if (node->num_values < 5) {
               printf("parse_level_config: tool_trigger requires 5 values\n");
               return -1;
            }
            tool_trigger_bin = (tool_trigger_t *)&bin[size];
            tool_trigger_bin->key = TOOL_TRIGGER;
            val = node->values;
            tool_trigger_bin->tool = tool2idx(val->val);
            val = val->next;
            tool_trigger_bin->x_min = atoi(val->val);
            val = val->next;
            tool_trigger_bin->y_min = atoi(val->val);
            val = val->next;
            tool_trigger_bin->x_max = atoi(val->val);
            val = val->next;
            tool_trigger_bin->y_max = atoi(val->val);
            size += sizeof(tool_trigger_t);
            break;

         case ITEM_TRIGGER:
            num_triggers++;
            if (num_triggers > MAX_TRIGGERS) {
               printf("parse_level_config: too many triggers (max: %d)\n",
                      MAX_TRIGGERS);
               return -1;
            }
            if (node->num_values < 7) {
               printf("parse_level_config: item_trigger requires 7 values\n");
               return -1;
            }
            item_trigger_bin = (item_trigger_t *)&bin[size];
            item_trigger_bin->key = ITEM_TRIGGER;
            val = node->values;
            item_trigger_bin->item = inv_item_index(val->val);
            val = val->next;
            num = atoi(val->val);
            item_trigger_bin->required[0] = num & 0x00FF;
            item_trigger_bin->required[1] = (num & 0xFF00) >> 8;
            val = val->next;
            num = atoi(val->val);
            item_trigger_bin->cost[0] = num & 0x00FF;
            item_trigger_bin->cost[1] = (num & 0xFF00) >> 8;
            val = val->next;
            item_trigger_bin->x_min = atoi(val->val);
            val = val->next;
            item_trigger_bin->y_min = atoi(val->val);
            val = val->next;
            item_trigger_bin->x_max = atoi(val->val);
            val = val->next;
            item_trigger_bin->y_max = atoi(val->val);
            size += sizeof(item_trigger_t);
            break;

         case IF:
         case IF_NOT:
         case SET_STATE:
         case CLEAR_STATE:
            if (node->num_values < 1) {
               printf("parse_level_config: no value specified for %s\n",
                     idx2key(node->key));
               return -1;
            }
            bin[size++] = node->key;
            num = state_index(node->values->val);
            if (num < 0) {
               new_state = malloc(sizeof(state_list_node_t));
               strn_tolower(new_state->label, MAX_STATE_LABEL+1, node->values->val);
               new_state->next = NULL;
               if (last_state == NULL) {
                  state_list = new_state;
               } else {
                  last_state->next = new_state;
               }
               last_state = new_state;
               num = state_index(node->values->val);
            }
            bin[size++] = num & 0x00FF;
            bin[size++] = (num & 0xFF00) >> 8;
            break;

         case GET_ITEM:
            if (node->num_values < 2) {
               printf("parse_level_config: get_item requires 2 values\n");
               return -1;
            }
            get_item_bin = (get_item_t *)&bin[size];
            get_item_bin->key = GET_ITEM;
            val = node->values;
            get_item_bin->item = inv_item_index(val->val);
            val = val->next;
            num = atoi(val->val);
            get_item_bin->quantity[0] = num & 0x00FF;
            get_item_bin->quantity[1] = (num & 0xFF00) >> 8;
            size += sizeof(get_item_t);
            break;

         case PLAY:
            if (node->num_values < 1) {
               printf("parse_level_config: no value specified for play\n");
               return -1;
            }
            bin[size++] = node->key;
            sound_idx = sfx_index(node->values->val);
            if (sound_idx < 0) {
               printf("parse_level_config: undefined sound id: %s\n", node->values->val);
            }
            bin[size++] = sound_idx;
            break;

         case SPRITE_FRAMES:
         case SPRITE:
         case SPRITE_HIDE:
         case TILES:
         case WAIT:
         case SPRITE_MOVE:
         case SPRITE_DEBUG:
            num = parse_animation_node(node, &bin[size]);
            if (num < 0) {
               printf("parse_level_config: error parsing %s\n",
                      idx2key(node->key));
               return -1;
            }
            size += num;
            break;
         default:
            printf("parse_level_config: WARNING: unexpected key (%s)\n",
                   idx2key(node->key));

      }
      if (size > MAX_LEVEL_SIZE) {
         printf("parse_level_config: Level configuration is too large\n");
      }
      node = node->next;
   }

   if (!bitmap_defined) {
      bank = level * 6 + 2;
      sprintf(bin_fn,"%03dL%d.%02d.BIN", zone, level, bank);
      create_black_bitmap(bin_fn, 200);
   }

   if (music_defined || (num_sounds > 0)) {
      music_sfx_buffer = malloc(8194);
      // first, two byte X16 header
      music_sfx_buffer[0] = 0x00;
      music_sfx_buffer[1] = 0x00;
      // calculate header size in loadable data
      msb_header_size = 3 + 2 * (num_sounds+1);
      if (music_defined) {
         music_sfx_buffer[2] = 1; // contains music
         music_sfx_buffer[3] = (uint8_t)(msb_header_size & 0x00FF);
         music_sfx_buffer[4] = (uint8_t)((msb_header_size & 0xFF00) >> 8);
         msb_size = vgm2x16opm(vgm_fn, &music_sfx_buffer[msb_header_size + 2]) + msb_header_size;
      } else {
         music_sfx_buffer[2] = 0; // no music
         msb_size = msb_header_size;
      }
      for (sound_idx = 0; sound_idx < num_sounds; sound_idx++) {
         music_sfx_buffer[5+sound_idx*2] = (uint8_t)(msb_size & 0x00FF);
         music_sfx_buffer[6+sound_idx*2] = (uint8_t)((msb_size & 0xFF00) >> 8);
         ifp = fopen(sound_fns[sound_idx], "rb");
         if (ifp == NULL) {
            printf("parse_level_config: error opening %s\n", sound_fns[sound_idx]);
            return -1;
         }
         while (!feof(ifp)) {
            if (fread(&sample,1,1,ifp) > 0) {
               music_sfx_buffer[2+msb_size++] = sample;
            }
         }
         fclose(ifp);
      }
      music_sfx_buffer[5+num_sounds*2] = (uint8_t)(msb_size & 0x00FF);
      music_sfx_buffer[6+num_sounds*2] = (uint8_t)((msb_size & 0xFF00) >> 8);
      bank = level * 6 + 6;
      sprintf(bin_fn,"%03dL%d.%02d.BIN", zone, level, bank);
      ofp = fopen(bin_fn,"wb");
      fwrite(music_sfx_buffer,1,msb_size+2,ofp);
      free(music_sfx_buffer);
   } else {
      // create blank music file
      bank = level * 6 + 6;
      sprintf(bin_fn,"%03dL%d.%02d.BIN", zone, level, bank);
      ofp = fopen(bin_fn,"wb");
      music_sfx_buffer = malloc(3);
      // first, two byte X16 header
      music_sfx_buffer[0] = 0x00;
      music_sfx_buffer[1] = 0x00;
      // then, just a single byte for the payload to indicate no music
      music_sfx_buffer[2] = 0x00;
      fwrite(music_sfx_buffer,1,3,ofp);
      free(music_sfx_buffer);
   }

   bank = level * 6 + 1;
   sprintf(bin_fn,"%03dL%d.%02d.BIN", zone, level, bank);
   ofp = fopen(bin_fn,"wb");
   fwrite(bin,1,size,ofp);
   fclose(ofp);

   free(bin);

   return 0;
}

void delete_state_list_node(state_list_node_t *node) {
   if (node != NULL) {
      delete_state_list_node(node->next);
      free(node);
   }
}

void delete_state_list() {
   delete_state_list_node(state_list);
}
