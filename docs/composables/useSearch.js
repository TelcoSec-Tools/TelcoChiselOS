export const useSearch = () => {
  const isSearchOpen = useState('searchOpen', () => false)
  
  const toggleSearch = () => {
    isSearchOpen.value = !isSearchOpen.value
  }
  
  const openSearch = () => {
    isSearchOpen.value = true
  }
  
  const closeSearch = () => {
    isSearchOpen.value = false
  }
  
  return {
    isSearchOpen,
    toggleSearch,
    openSearch,
    closeSearch
  }
}
