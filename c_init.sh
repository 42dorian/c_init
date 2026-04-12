#!/bin/bash

# REPO LINKS - ADD YOURS HERE
GNL_REPO="https://github.com/42dorian/get_next_line.git"
PRINTF_REPO="https://github.com/42dorian/ft_printf.git"
LIBFT_REPO="https://github.com/42dorian/libft.git"

read -p "Project name: " name
read -p "Your 42 login: " login
mkdir -p "$name/src" "$name/include"
cd "$name"

# --- Clone helper with error handling ---
clone_lib() {
	local repo="$1" dir="$2"
	if git clone "$repo" "$dir" 2>/dev/null; then
		rm -rf "$dir/.git"
		mv "$dir" include/
		return 0
	else
		echo "⚠  Failed to clone $repo — skipping."
		return 1
	fi
}

gnl="n"
printf_="n"
libft="n"

read -p "Need get_next_line? (y/n): " ans
if [ "$ans" = "y" ]; then
	clone_lib "$GNL_REPO" "get_next_line" && gnl="y"
fi

read -p "Need ft_printf? (y/n): " ans
if [ "$ans" = "y" ]; then
	clone_lib "$PRINTF_REPO" "ft_printf" && printf_="y"
fi

read -p "Need libft? (y/n): " ans
if [ "$ans" = "y" ]; then
	clone_lib "$LIBFT_REPO" "libft" && libft="y"
fi

# --- Discover GNL .c files explicitly ---
GNL_FILES=""
if [ "$gnl" = "y" ]; then
	for f in include/get_next_line/*.c; do
		[ -f "$f" ] && GNL_FILES="${GNL_FILES:+$GNL_FILES }$f"
	done
fi

# --- .gitignore ---
cat > .gitignore << 'EOF'
*.o
*.a
*.d
a.out
.DS_Store
.vscode/
EOF

# --- Makefile ---
{
cat << EOF
NAME = $name

SOURCE = src/main.c

CFLAGS = -Wall -Wextra -Werror -g

OBJECTS = \$(SOURCE:.c=.o)

EOF

[ "$libft" = "y" ] && echo "LIBFT_DIR = include/libft"
[ "$printf_" = "y" ] && echo "FT_PRINTF_DIR = include/ft_printf"
if [ "$gnl" = "y" ]; then
	echo "GNL_DIR = include/get_next_line"
	echo ""
	first=1
	for f in $GNL_FILES; do
		if [ "$first" = "1" ]; then
			printf "GNL_SRC = %s" "$f"
			first=0
		else
			printf " \\\\\n\t\t\t%s" "$f"
		fi
	done
	echo ""
	echo 'GNL_OBJ = $(GNL_SRC:.c=.o)'
fi
echo ""

[ "$libft" = "y" ] && echo 'LIBFT = $(LIBFT_DIR)/libft.a'
[ "$printf_" = "y" ] && echo 'FT_PRINTF = $(FT_PRINTF_DIR)/libftprintf.a'
echo ""

cat << 'EOF'
CC = cc
RM = rm -f

all: $(NAME)

EOF

if [ "$libft" = "y" ]; then
cat << 'EOF'
$(LIBFT):
	@make -C $(LIBFT_DIR)

EOF
fi

if [ "$printf_" = "y" ]; then
cat << 'EOF'
$(FT_PRINTF):
	@make -C $(FT_PRINTF_DIR)

EOF
fi

# Header dependencies for pattern rule
HDEPS="src/$name.h"
[ "$libft" = "y" ] && HDEPS="$HDEPS include/libft/libft.h"
[ "$printf_" = "y" ] && HDEPS="$HDEPS include/ft_printf/ft_printf.h"
[ "$gnl" = "y" ] && HDEPS="$HDEPS include/get_next_line/get_next_line.h"

echo "%.o: %.c $HDEPS"
echo '	$(CC) $(CFLAGS) -c $< -o $@'
echo ""

# Link rule
LINK_DEPS='$(OBJECTS)'
LINK_LIBS=""
[ "$libft" = "y" ] && LINK_DEPS='$(LIBFT) '"$LINK_DEPS" && LINK_LIBS='$(LIBFT) '"$LINK_LIBS"
[ "$printf_" = "y" ] && LINK_DEPS='$(FT_PRINTF) '"$LINK_DEPS" && LINK_LIBS='$(FT_PRINTF) '"$LINK_LIBS"
[ "$gnl" = "y" ] && LINK_DEPS="$LINK_DEPS "'$(GNL_OBJ)' && LINK_LIBS="$LINK_LIBS "'$(GNL_OBJ)'

echo "\$(NAME): $LINK_DEPS"
echo "	\$(CC) \$(CFLAGS) \$(OBJECTS) $LINK_LIBS -o \$(NAME)"
echo ""

echo "clean:"
[ "$libft" = "y" ] && echo '	@make -C $(LIBFT_DIR) clean'
[ "$printf_" = "y" ] && echo '	@make -C $(FT_PRINTF_DIR) clean'
[ "$gnl" = "y" ] && echo '	$(RM) $(GNL_OBJ)'
echo '	$(RM) $(OBJECTS)'
echo ""

echo "fclean: clean"
[ "$libft" = "y" ] && echo '	@make -C $(LIBFT_DIR) fclean'
[ "$printf_" = "y" ] && echo '	@make -C $(FT_PRINTF_DIR) fclean'
echo '	$(RM) $(NAME)'
echo ""

cat << 'EOF'
re: fclean all

.PHONY: clean fclean re all
EOF

} > Makefile

# --- README.md ---
{
cat << EOF
# $name

*This project was created as part of the 42 curriculum by **$login**.*

## Description

<!-- Add your project description here -->

## Instructions

### Compile the program
\`\`\`
make
\`\`\`

### Run the program
\`\`\`
./$name
\`\`\`

### Clean build files
\`\`\`
make clean    # remove object files
make fclean   # remove object files and binary
make re       # full recompile
\`\`\`
EOF

if [ "$gnl" = "y" ] || [ "$printf_" = "y" ] || [ "$libft" = "y" ]; then
	echo ""
	echo "## Libraries used"
	echo ""
	[ "$libft" = "y" ] && echo "- **libft** — custom C standard library"
	[ "$printf_" = "y" ] && echo "- **ft_printf** — custom printf implementation"
	[ "$gnl" = "y" ] && echo "- **get_next_line** — line-by-line file reader"
fi

cat << 'EOF'

## Resources

<!-- Add helpful links, peers you discussed with, etc. -->
EOF

} > README.md

# --- Starter main.c ---
cat > src/main.c << EOF
#include "$name.h"

int	main(int argc, char **argv)
{
	(void)argc;
	(void)argv;
	return (0);
}
EOF

# --- Starter header ---
HEADER_GUARD=$(echo "${name}" | tr '[:lower:]-' '[:upper:]_')
{
echo "#ifndef ${HEADER_GUARD}_H"
echo "# define ${HEADER_GUARD}_H"
echo ""
echo "# include <unistd.h>"
echo "# include <stdlib.h>"
[ "$libft" = "y" ] && echo "# include \"../include/libft/libft.h\""
[ "$printf_" = "y" ] && echo "# include \"../include/ft_printf/ft_printf.h\""
[ "$gnl" = "y" ] && echo "# include \"../include/get_next_line/get_next_line.h\""
echo ""
echo "#endif"
} > "src/$name.h"

# --- Git init ---
LIBS=""
[ "$gnl" = "y" ] && LIBS="get_next_line"
[ "$printf_" = "y" ] && LIBS="${LIBS:+$LIBS, }ft_printf"
[ "$libft" = "y" ] && LIBS="${LIBS:+$LIBS, }libft"

MSG="init: created src/, Makefile, README.md, .gitignore"
[ -n "$LIBS" ] && MSG="$MSG; added $LIBS"

git init
git add .
git commit -m "$MSG"

echo ""
echo "Done. Project '$name' ready."
