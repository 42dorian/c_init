#!/bin/bash

# REPO LINKS - ADD YOURS HERE
GNL_REPO="https://github.com/42dorian/get_next_line.git"
PRINTF_REPO="https://github.com/42dorian/ft_printf.git"
LIBFT_REPO="https://github.com/42dorian/libft.git"

read -p "Project name: " name
mkdir -p "$name/src" "$name/include"
cd "$name"

read -p "Need get_next_line? (y/n): " gnl
if [ "$gnl" = "y" ]; then
	git clone "$GNL_REPO" get_next_line
	rm -rf get_next_line/.git
	mv get_next_line include/
fi

read -p "Need ft_printf? (y/n): " printf
if [ "$printf" = "y" ]; then
	git clone "$PRINTF_REPO" ft_printf
	rm -rf ft_printf/.git
	mv ft_printf include/
fi

read -p "Need libft? (y/n): " libft
if [ "$libft" = "y" ]; then
	git clone "$LIBFT_REPO" libft
	rm -rf libft/.git
	mv libft include/
fi

cat > .gitignore << 'EOF'
*.o
*.a
*.d
a.out
.DS_Store
.vscode/
 
EOF
 
LIBS=""
[ "$gnl" = "y" ] && LIBS="get_next_line"
[ "$printf" = "y" ] && LIBS="${LIBS:+$LIBS, }ft_printf"
[ "$libft" = "y" ] && LIBS="${LIBS:+$LIBS, }libft"
 
MSG="init: created src/, .gitignore"
[ -n "$LIBS" ] && MSG="$MSG; added $LIBS"
 
git init
git add .
git commit -m "$MSG"


echo "Done. Project '$name' ready."
